import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_usage.dart';

// Events
abstract class MaterialUsageEvent {}

class AddMaterialUsageEvent extends MaterialUsageEvent {
  final MaterialUsage materialUsage;
  AddMaterialUsageEvent(this.materialUsage);
}

class UpdateMaterialUsageEvent extends MaterialUsageEvent {
  final String materialUsageId;
  final MaterialUsage materialUsage;
  UpdateMaterialUsageEvent(this.materialUsageId, this.materialUsage);
}

class DeleteMaterialUsageEvent extends MaterialUsageEvent {
  final String materialUsageId;
  DeleteMaterialUsageEvent(this.materialUsageId);
}

class FinishedMaterialUsageEvent extends MaterialUsageEvent {
  final String materialUsageId;
  FinishedMaterialUsageEvent(this.materialUsageId);
}

// States
abstract class MaterialUsageBlocState {}

class LoadingState extends MaterialUsageBlocState {}

class SuccessState extends MaterialUsageBlocState {}

class LoadedState extends MaterialUsageBlocState {
  final MaterialUsage materialUsage;
  LoadedState(this.materialUsage);
}

class MaterialUsageUpdatedState extends MaterialUsageBlocState {}

class MaterialUsageDeletedState extends MaterialUsageBlocState {}

class ErrorState extends MaterialUsageBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class MaterialUsageBloc
    extends Bloc<MaterialUsageEvent, MaterialUsageBlocState> {
  late FirebaseFirestore _firestore;
  final HttpsCallable materialUsageValidationCallable;

  MaterialUsageBloc() : materialUsageValidationCallable = FirebaseFunctions.instance.httpsCallable('materialUsageValidation'), super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<MaterialUsageBlocState> mapEventToState(
      MaterialUsageEvent event) async* {
    if (event is AddMaterialUsageEvent) {
      yield LoadingState();

      final batch = event.materialUsage.batch;
      final catatan = event.materialUsage.catatan;
      final productionOrderId = event.materialUsage.productionOrderId;
      final materialRequestId = event.materialUsage.materialRequestId;
      final status = event.materialUsage.status;
      final statusMu = event.materialUsage.statusMu;
      final tanggalPenggunaan = event.materialUsage.tanggalPenggunaan;
      final materials = event.materialUsage.detailMaterialUsageList;

      if(productionOrderId.isNotEmpty){
        if(materialRequestId.isNotEmpty){
           try {
             final HttpsCallableResult<dynamic> result = await materialUsageValidationCallable.call(<String, dynamic>{
              'materials': materials.map((material) => material.toJson()).toList(),
              'materialRequestId': materialRequestId,
              'productionOrderId': productionOrderId,
              'batch': batch,
              'mode': 'add'
            });

            if (result.data['success'] == true) {
               // Generate a new material usage ID (or use an existing one if you have it)
            final nextMaterialUsageId = await _generateNextMaterialUsageId();

            // Create a reference to the material usage document using the appropriate ID
            final materialUsageRef =
                _firestore.collection('material_usages').doc(nextMaterialUsageId);

            // Set the material usage data
            final Map<String, dynamic> materialUsageData = {
              'id': nextMaterialUsageId,
              'batch': batch,
              'catatan': catatan,
              'production_order_id': productionOrderId,
              'material_request_id' :materialRequestId,
              'status': status,
              'status_mu': statusMu,
              'tanggal_penggunaan': tanggalPenggunaan,
            };

            // Add the material usage data to Firestore
            await materialUsageRef.set(materialUsageData);

            // Create a reference to the 'detail_material_usages' subcollection within the material usage document
            final detailMaterialUsageRef =
                materialUsageRef.collection('detail_material_usages');

            if (event.materialUsage.detailMaterialUsageList.isNotEmpty) {
              int detailCount = 1;
              for (var detailMaterialUsage
                  in event.materialUsage.detailMaterialUsageList) {
                final nextDetailMaterialUsageId =
                    '$nextMaterialUsageId${'D${detailCount.toString().padLeft(3, '0')}'}';

                // Add the detail material usage document to the 'detail_material_usages' collection
                await detailMaterialUsageRef.add({
                  'id': nextDetailMaterialUsageId,
                  'material_usage_id': nextMaterialUsageId,
                  'jumlah': detailMaterialUsage.jumlah,
                  'material_id': detailMaterialUsage.materialId,
                  'satuan': detailMaterialUsage.satuan,
                  'status': detailMaterialUsage.status,
                });
                detailCount++;
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
          yield ErrorState("nomor permintaan bahan tidak boleh kosong,\n permintaan bahan harus dilakukan terlebih dahulu");
        }
      }else{
        yield ErrorState("nomor perintah produksi tidak boleh kosong");
      }
    } else if (event is UpdateMaterialUsageEvent) {
      yield LoadingState();

      final batch = event.materialUsage.batch;
      final catatan = event.materialUsage.catatan;
      final productionOrderId = event.materialUsage.productionOrderId;
      final materialRequestId = event.materialUsage.materialRequestId;
      final status = event.materialUsage.status;
      final statusMu = event.materialUsage.statusMu;
      final tanggalPenggunaan = event.materialUsage.tanggalPenggunaan;
      final materials = event.materialUsage.detailMaterialUsageList;

      if(productionOrderId.isNotEmpty){
        if(materialRequestId.isNotEmpty){
          try {
            final HttpsCallableResult<dynamic> result = await materialUsageValidationCallable.call(<String, dynamic>{
            'materials': materials.map((material) => material.toJson()).toList(),
            'materialRequestId': materialRequestId,
            'productionOrderId': productionOrderId,
            'batch': batch,
            'mode': 'edit'
            });

            if (result.data['success'] == true) {
                    // Get a reference to the material usage document to be updated
            final materialUsageToUpdateRef =
                _firestore.collection('material_usages').doc(event.materialUsageId);

            // Set the new material usage data
            final Map<String, dynamic> materialUsageData = {
              'id': event.materialUsageId,
              'batch':batch,
              'catatan':catatan,
              'production_order_id': productionOrderId,
              'material_request_id' :materialRequestId,
              'status': status,
              'status_mu': statusMu,
              'tanggal_penggunaan': tanggalPenggunaan,
            };

            // Update the material usage data within the existing document
            await materialUsageToUpdateRef.set(materialUsageData);

            // Delete all documents within the 'detail_material_usages' subcollection first
            final detailMaterialUsageCollectionRef =
                materialUsageToUpdateRef.collection('detail_material_usages');
            final detailMaterialUsageDocs =
                await detailMaterialUsageCollectionRef.get();
            for (var doc in detailMaterialUsageDocs.docs) {
              await doc.reference.delete();
            }

            // Add the new detail material usage documents to the 'detail_material_usages' subcollection
            if (event.materialUsage.detailMaterialUsageList.isNotEmpty) {
              int detailCount = 1;
              for (var detailMaterialUsage
                  in event.materialUsage.detailMaterialUsageList) {
                final nextDetailMaterialUsageId =
                    'D${detailCount.toString().padLeft(3, '0')}';
                final detailId = event.materialUsageId + nextDetailMaterialUsageId;

                // Add the detail material usage documents to the 'detail_material_usages' collection
                await detailMaterialUsageCollectionRef.add({
                  'id': detailId,
                  'material_usage_id': event.materialUsageId,
                  'jumlah': detailMaterialUsage.jumlah,
                  'material_id': detailMaterialUsage.materialId,
                  'satuan': detailMaterialUsage.satuan,
                  'status': detailMaterialUsage.status,
                });
                detailCount++;
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
          yield ErrorState("nomor permintaan bahan tidak boleh kosong");
        }
      }else{
        yield ErrorState("nomor perintah produksi tidak boleh kosong");
      }

    } else if (event is DeleteMaterialUsageEvent) {
      yield LoadingState();
      try {
        // Get a reference to the material usage document to be deleted
        final materialUsageToDeleteRef =
            _firestore.collection('material_usages').doc(event.materialUsageId);

        // Get a reference to the 'detail_material_usages' subcollection within the material usage document
        final detailMaterialUsageCollectionRef =
            materialUsageToDeleteRef.collection('detail_material_usages');

        // Delete all documents within the 'detail_material_usages' subcollection
        final detailMaterialUsageDocs =
            await detailMaterialUsageCollectionRef.get();
        for (var doc in detailMaterialUsageDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents within the subcollection, delete the material usage document itself
        await materialUsageToDeleteRef.delete();

        yield MaterialUsageDeletedState();
      } catch (e) {
        yield ErrorState("Failed to delete Material Usage.");
      }
    }else if(event is FinishedMaterialUsageEvent){
      yield LoadingState();
      try {
       
        final materialUsageRef = _firestore.collection('material_usages').doc(event.materialUsageId);

        await materialUsageRef.update({
          'status_mu': 'Selesai',
        });

        yield SuccessState();
      } catch (e) {
        yield ErrorState("Failed to delete Material Usage.");
      }
    }
  }

  Future<String> _generateNextMaterialUsageId() async {
    final materialUsagesRef = _firestore.collection('material_usages');
    final QuerySnapshot snapshot = await materialUsagesRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int materialUsageCount = 1;

    while (true) {
      final nextMaterialUsageId =
          'MU${materialUsageCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextMaterialUsageId)) {
        return nextMaterialUsageId;
      }
      materialUsageCount++;
    }
  }
}
