import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/billofmaterial.dart';

// Events
abstract class BillOfMaterialEvent {}

class AddBillOfMaterialEvent extends BillOfMaterialEvent {
  final BillOfMaterial billOfMaterial;
  AddBillOfMaterialEvent(this.billOfMaterial);
}

class UpdateBillOfMaterialEvent extends BillOfMaterialEvent {
  final String bomId;
  final BillOfMaterial billOfMaterial;
  UpdateBillOfMaterialEvent(this.bomId, this.billOfMaterial);
}

class DeleteBillOfMaterialEvent extends BillOfMaterialEvent {
  final String bomId;
  DeleteBillOfMaterialEvent(this.bomId);
}

// States
abstract class BillOfMaterialBlocState {}

class LoadingState extends BillOfMaterialBlocState {}

class SuccessState extends BillOfMaterialBlocState {}

class LoadedState extends BillOfMaterialBlocState {
  final BillOfMaterial billOfMaterial;
  LoadedState(this.billOfMaterial);
}

class BillOfMaterialUpdatedState extends BillOfMaterialBlocState {}

class BillOfMaterialDeletedState extends BillOfMaterialBlocState {}

class ErrorState extends BillOfMaterialBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class BillOfMaterialBloc extends Bloc<BillOfMaterialEvent, BillOfMaterialBlocState> {
  late FirebaseFirestore _firestore;
  final HttpsCallable _bomValidationCallable;
  final HttpsCallable _detailBOMValidationCallable;

   BillOfMaterialBloc()
      : _bomValidationCallable = FirebaseFunctions.instance.httpsCallable('bomValidation'),
        _detailBOMValidationCallable = FirebaseFunctions.instance.httpsCallable('detailBOMValidation'), super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<BillOfMaterialBlocState> mapEventToState(BillOfMaterialEvent event) async* {
    if (event is AddBillOfMaterialEvent) {
      yield LoadingState();

      final productId = event.billOfMaterial.productId;
      final statusBom = event.billOfMaterial.statusBOM;
      final tanggalPembuatan = event.billOfMaterial.tanggalPembuatan;
      final materials = event.billOfMaterial.detailBOMList;

      if(productId.isNotEmpty){
            try {
              final HttpsCallableResult<dynamic> result = await _bomValidationCallable.call(<String, dynamic>{
                'materials': materials?.map((material) => material.toJson()).toList(),
              });

                if (result.data['success'] == true) {
                    // Generate a new BOM ID (or use an existing one if you have it)
                    final nextBomId = await _generateNextBomId();

                    // Create a reference to the BOM document using the appropriate ID
                    final bomRef = _firestore.collection('bill_of_materials').doc(nextBomId);
                    final nextVersion = await _generateNextVersion(event.billOfMaterial.productId);

                    // Set BOM data
                    final Map<String, dynamic> bomData = {
                      'id': nextBomId,
                      'product_id': productId,
                      'status_bom': statusBom,
                      'tanggal_pembuatan': tanggalPembuatan,
                      'versi_bom': nextVersion,
                    };

                    // Add BOM data to Firestore
                    await bomRef.set(bomData);

                    // Create a reference to the 'bom_details' subcollection within the BOM document
                    final bomDetailsRef = bomRef.collection('detail_bill_of_materials');

                    if (event.billOfMaterial.detailBOMList != null &&
                        event.billOfMaterial.detailBOMList!.isNotEmpty) {
                      int detailCount = 1;
                      for (var bomDetail in event.billOfMaterial.detailBOMList!) {

                        final HttpsCallableResult<dynamic> res = await _detailBOMValidationCallable.call(<String, dynamic>{
                            'material_id' : bomDetail.materialId,
                            'bom_id' : nextBomId,
                            'jumlah' : bomDetail.jumlah
                        });

                        if(res.data['add'] ==true){
                            final nextBomDetailId ='$nextBomId${'D${detailCount.toString().padLeft(3, '0')}'}';
                            // Add a document for each BOM detail in the 'bom_details' collection
                            await bomDetailsRef.add({
                              'id' : nextBomDetailId,
                              'bom_id' : nextBomId,
                              'jumlah': bomDetail.jumlah,
                              'material_id': bomDetail.materialId,
                              'batch': bomDetail.batch,
                              'satuan' : bomDetail.satuan,
                              'status' : bomDetail.status,
                            });
                            detailCount++;
                        }

                      }
                    }
                  
                    yield SuccessState();
                }else{
                  yield ErrorState(result.data['message']);
                }

            } catch (e) {
              yield ErrorState(e.toString());
            }
      }else{
        yield ErrorState('kode produk harus diisi');
      }

    } else if (event is UpdateBillOfMaterialEvent) {
      yield LoadingState();

      final productId = event.billOfMaterial.productId;
      final statusBom = event.billOfMaterial.statusBOM;
      final tanggalPembuatan = event.billOfMaterial.tanggalPembuatan;
      final materials = event.billOfMaterial.detailBOMList;
      
      if(productId.isNotEmpty){
         try {
            final HttpsCallableResult<dynamic> result = await _bomValidationCallable.call(<String, dynamic>{
              'materials': materials?.map((material) => material.toJson()).toList(),
            });

            if (result.data['success'] == true) {
              final bomToUpdateRef = _firestore.collection('bill_of_materials').doc(event.bomId);
              final nextVersion = await _generateNextVersion(event.billOfMaterial.productId);

              // Set the new BOM data
              final Map<String, dynamic> bomData = {
                'id': event.bomId,
                'product_id': productId,
                'status_bom': statusBom,
                'tanggal_pembuatan': tanggalPembuatan,
                'versi_bom': nextVersion
              };

              // Update the BOM data in the existing document
              await bomToUpdateRef.set(bomData);

              // Delete all documents in the 'bom_details' subcollection first
              final bomDetailsCollectionRef = bomToUpdateRef.collection('detail_bill_of_materials');
              final bomDetailDocs = await bomDetailsCollectionRef.get();
              for (var doc in bomDetailDocs.docs) {
                await doc.reference.delete();
              }

              // Add the new BOM detail documents to the 'bom_details' subcollection
              if (event.billOfMaterial.detailBOMList != null &&
                  event.billOfMaterial.detailBOMList!.isNotEmpty) {
                int detailCount = 1;
                for (var bomDetail in event.billOfMaterial.detailBOMList!) {

                   final HttpsCallableResult<dynamic> res = await _detailBOMValidationCallable.call(<String, dynamic>{
                      'material_id' : bomDetail.materialId,
                      'bom_id' : event.bomId,
                      'jumlah' : bomDetail.jumlah
                  });

                  if(res.data['add'] ==true){
                    final nextBomDetailId = 'D${detailCount.toString().padLeft(3, '0')}';
                    final detailId = event.bomId + nextBomDetailId;

                    await bomDetailsCollectionRef.add({
                      'id': detailId,
                      'bom_id': event.bomId,
                      'jumlah': bomDetail.jumlah,
                      'material_id': bomDetail.materialId,
                      'batch': bomDetail.batch,
                      'satuan': bomDetail.satuan,
                      'status': bomDetail.status,
                    });
                    detailCount++;
                  }
                }
              }
              
              yield SuccessState();
            }else{
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
      }else{
        yield ErrorState('kode produk harus diisi');
      }

    } else if (event is DeleteBillOfMaterialEvent) {
      yield LoadingState();
      try {
        // Get a reference to the BOM document to be deleted
        final bomToDeleteRef = _firestore.collection('bill_of_materials').doc(event.bomId);

        // Get a reference to the 'bom_details' subcollection within the BOM document
        final bomDetailsCollectionRef = bomToDeleteRef.collection('detail_bill_of_materials');

        // Delete all documents in the 'bom_details' subcollection
        final bomDetailDocs = await bomDetailsCollectionRef.get();
        for (var doc in bomDetailDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents in the subcollection, delete the BOM document itself
        await bomToDeleteRef.delete();

        yield BillOfMaterialDeletedState();
      } catch (e) {
        yield ErrorState("Failed to delete Bill Of Material.");
      }
    }
  }

Future<int> _generateNextVersion(String productId) async {
  final bomsRef = FirebaseFirestore.instance.collection('bill_of_materials');
  final QuerySnapshot snapshot = await bomsRef.where('product_id', isEqualTo: productId).get();
  final List<int> existingVersions = [];
  

  // Iterasi melalui dokumen yang sesuai dengan kriteria
  for (QueryDocumentSnapshot doc in snapshot.docs) {
    final versiBom = doc['versi_bom'] as int;
    existingVersions.add(versiBom);
  }

  int nextVersion = 1;

  if (existingVersions.isNotEmpty) {
    // Temukan versi terbaru
    final latestVersion = existingVersions.reduce((value, element) => value > element ? value : element);
    nextVersion = latestVersion + 1;
  }

  return nextVersion;
}


  Future<String> _generateNextBomId() async {
    final bomsRef = _firestore.collection('bill_of_materials');
    final QuerySnapshot snapshot = await bomsRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int bomCount = 1;

    while (true) {
      final nextBomId = 'BOM${bomCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextBomId)) {
        return nextBomId;
      }
      bomCount++;
    }
  }
}
