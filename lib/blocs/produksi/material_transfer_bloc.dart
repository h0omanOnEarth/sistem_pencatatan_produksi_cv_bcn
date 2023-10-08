import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_transfer.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/notificationService.dart';

// Events
abstract class MaterialTransferEvent {}

class AddMaterialTransferEvent extends MaterialTransferEvent {
  final MaterialTransfer materialTransfer;
  AddMaterialTransferEvent(this.materialTransfer);
}

class UpdateMaterialTransferEvent extends MaterialTransferEvent {
  final String materialTransferId;
  final MaterialTransfer materialTransfer;
  UpdateMaterialTransferEvent(this.materialTransferId, this.materialTransfer);
}

class DeleteMaterialTransferEvent extends MaterialTransferEvent {
  final String materialTransferId;
  DeleteMaterialTransferEvent(this.materialTransferId);
}

// States
abstract class MaterialTransferBlocState {}

class MaterialTransferLoadingState extends MaterialTransferBlocState {}

class SuccessState extends MaterialTransferBlocState{}

class MaterialTransferLoadedState extends MaterialTransferBlocState {
  final MaterialTransfer materialTransfer;
  MaterialTransferLoadedState(this.materialTransfer);
}

class MaterialTransferUpdatedState extends MaterialTransferBlocState {}

class MaterialTransferDeletedState extends MaterialTransferBlocState {}

class MaterialTransferErrorState extends MaterialTransferBlocState {
  final String errorMessage;
  MaterialTransferErrorState(this.errorMessage);
}

// BLoC
class MaterialTransferBloc
    extends Bloc<MaterialTransferEvent, MaterialTransferBlocState> {
  late FirebaseFirestore _firestore;
  final notificationService = NotificationService();
  final HttpsCallable materialTransferCallable;

  MaterialTransferBloc() : materialTransferCallable = FirebaseFunctions.instance.httpsCallable('materialTransferValidation'), super(MaterialTransferLoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<MaterialTransferBlocState> mapEventToState(
      MaterialTransferEvent event) async* {
    if (event is AddMaterialTransferEvent) {
      yield MaterialTransferLoadingState();

      final materialRequestId = event.materialTransfer.materialRequestId;
      final materials = event.materialTransfer.detailList;

      if(materialRequestId.isNotEmpty){
      try {
        final HttpsCallableResult<dynamic> result = await materialTransferCallable.call(<String, dynamic>{
        'materials': materials.map((material) => material.toJson()).toList(),
        'materialRequestId': materialRequestId,
      });

      if (result.data['success'] == true) {
         final nextMaterialTransferId = await _generateNextMaterialTransferId();

        // Create a reference to the material transfer document using the appropriate ID
        final materialTransferRef =
            _firestore.collection('material_transfers').doc(nextMaterialTransferId);

        // Set the material transfer data
        final Map<String, dynamic> materialTransferData = {
          'id': nextMaterialTransferId,
          'material_request_id': materialRequestId,
          'status_mtr': event.materialTransfer.statusMtr,
          'tanggal_pemindahan': event.materialTransfer.tanggalPemindahan,
          'catatan': event.materialTransfer.catatan,
          'status': event.materialTransfer.status,
        };

        // Add the material transfer data to Firestore
        await materialTransferRef.set(materialTransferData);

        // Create a reference to the 'detail_material_transfers' subcollection within the material transfer document
        final detailMaterialTransferRef =
            materialTransferRef.collection('detail_material_transfers');

        if (event.materialTransfer.detailList.isNotEmpty) {
          int detailCount = 1;
          for (var detailMaterialTransfer
              in event.materialTransfer.detailList) {
            final nextDetailMaterialTransferId =
                '$nextMaterialTransferId${'D${detailCount.toString().padLeft(3, '0')}'}';

            // Add the detail material transfer document to the 'detail_material_transfers' collection
            await detailMaterialTransferRef.add({
              'id': nextDetailMaterialTransferId,
              'material_transfer_id': nextMaterialTransferId,
              'jumlah_bom': detailMaterialTransfer.jumlahBom,
              'material_id': detailMaterialTransfer.materialId,
              'satuan': detailMaterialTransfer.satuan,
              'status': detailMaterialTransfer.status,
              'stok': detailMaterialTransfer.stok,
            });
            detailCount++;
          }
        }

        await notificationService.addNotification('Terdapat pemindahan bahan baru $nextMaterialTransferId untuk ${event.materialTransfer.materialRequestId}', 'Produksi');

        yield SuccessState();
      }else{
        yield MaterialTransferErrorState(result.data['message']);
      }

      } catch (e) {
        yield MaterialTransferErrorState(e.toString());
      }
      }else{
        yield MaterialTransferErrorState('nomor permintaan bahan tidak boleh kosong');
      }
    } else if (event is UpdateMaterialTransferEvent) {
      yield MaterialTransferLoadingState();
      final materialRequestId = event.materialTransfer.materialRequestId;
      final materials = event.materialTransfer.detailList;

      if(materialRequestId.isNotEmpty){
      try {
      final HttpsCallableResult<dynamic> result = await materialTransferCallable.call(<String, dynamic>{
      'materials': materials.map((material) => material.toJson()).toList(),
      'materialRequestId': materialRequestId,
      });

      if (result.data['success'] == true) {
        // Get a reference to the material transfer document to be updated
        final materialTransferToUpdateRef =
            _firestore.collection('material_transfers').doc(event.materialTransferId);

        // Set the new material transfer data
        final Map<String, dynamic> materialTransferData = {
          'id': event.materialTransferId,
          'material_request_id': event.materialTransfer.materialRequestId,
          'status_mtr': event.materialTransfer.statusMtr,
          'tanggal_pemindahan': event.materialTransfer.tanggalPemindahan,
          'catatan': event.materialTransfer.catatan,
          'status': event.materialTransfer.status,
        };

        // Update the material transfer data within the existing document
        await materialTransferToUpdateRef.set(materialTransferData);

        // Delete all documents within the 'detail_material_transfers' subcollection first
        final detailMaterialTransferCollectionRef =
            materialTransferToUpdateRef.collection('detail_material_transfers');
        final detailMaterialTransferDocs =
            await detailMaterialTransferCollectionRef.get();
        for (var doc in detailMaterialTransferDocs.docs) {
          await doc.reference.delete();
        }

        // Add the new detail material transfer documents to the 'detail_material_transfers' subcollection
        if (event.materialTransfer.detailList.isNotEmpty) {
          int detailCount = 1;
          for (var detailMaterialTransfer
              in event.materialTransfer.detailList) {
            final nextDetailMaterialTransferId =
                'D${detailCount.toString().padLeft(3, '0')}';
            final detailId = event.materialTransferId + nextDetailMaterialTransferId;

            // Add the detail material transfer documents to the 'detail_material_transfers' collection
            await detailMaterialTransferCollectionRef.add({
              'id': detailId,
              'material_transfer_id': event.materialTransferId,
              'jumlah_bom': detailMaterialTransfer.jumlahBom,
              'material_id': detailMaterialTransfer.materialId,
              'satuan': detailMaterialTransfer.satuan,
              'status': detailMaterialTransfer.status,
              'stok': detailMaterialTransfer.stok,
            });
            detailCount++;
          }
        }
        yield SuccessState();
      }else{
        yield MaterialTransferErrorState(result.data['message']);
      }
      
      } catch (e) {
        yield MaterialTransferErrorState(e.toString());
      }
      }else{
        yield MaterialTransferErrorState("nomor permintaan bahan tidak boleh kosong");
      }

    } else if (event is DeleteMaterialTransferEvent) {
      yield MaterialTransferLoadingState();
      try {
        // Get a reference to the material transfer document to be deleted
        final materialTransferToDeleteRef =
            _firestore.collection('material_transfers').doc(event.materialTransferId);

        // Get a reference to the 'detail_material_transfers' subcollection within the material transfer document
        final detailMaterialTransferCollectionRef =
            materialTransferToDeleteRef.collection('detail_material_transfers');

        // Delete all documents within the 'detail_material_transfers' subcollection
        final detailMaterialTransferDocs =
            await detailMaterialTransferCollectionRef.get();
        for (var doc in detailMaterialTransferDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents within the subcollection, delete the material transfer document itself
        await materialTransferToDeleteRef.delete();

        yield MaterialTransferDeletedState();
      } catch (e) {
        yield MaterialTransferErrorState("Failed to delete Material Transfer.");
      }
    }
  }

  Future<String> _generateNextMaterialTransferId() async {
    final materialTransfersRef = _firestore.collection('material_transfers');
    final QuerySnapshot snapshot = await materialTransfersRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int materialTransferCount = 1;

    while (true) {
      final nextMaterialTransferId =
          'MTR${materialTransferCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextMaterialTransferId)) {
        return nextMaterialTransferId;
      }
      materialTransferCount++;
    }
  }
}
