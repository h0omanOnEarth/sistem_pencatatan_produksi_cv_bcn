import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/notificationService.dart';

// Events
abstract class MaterialRequestEvent {}

class AddMaterialRequestEvent extends MaterialRequestEvent {
  final MaterialRequest materialRequest;
  AddMaterialRequestEvent(this.materialRequest);
}

class UpdateMaterialRequestEvent extends MaterialRequestEvent {
  final String materialRequestId;
  final MaterialRequest materialRequest;
  UpdateMaterialRequestEvent(this.materialRequestId, this.materialRequest);
}

class DeleteMaterialRequestEvent extends MaterialRequestEvent {
  final String materialRequestId;
  DeleteMaterialRequestEvent(this.materialRequestId);
}

// States
abstract class MaterialRequestBlocState {}

class LoadingState extends MaterialRequestBlocState {}

class SuccessState extends MaterialRequestBlocState {}

class LoadedState extends MaterialRequestBlocState {
  final MaterialRequest materialRequest;
  LoadedState(this.materialRequest);
}

class MaterialRequestUpdatedState extends MaterialRequestBlocState {}

class MaterialRequestDeletedState extends MaterialRequestBlocState {}

class ErrorState extends MaterialRequestBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class MaterialRequestBloc
    extends Bloc<MaterialRequestEvent, MaterialRequestBlocState> {
  late FirebaseFirestore _firestore;
  final notificationService = NotificationService();
  final HttpsCallable materialReqValidationCallable;

  MaterialRequestBloc() : materialReqValidationCallable = FirebaseFunctions.instance.httpsCallable('materialRequestValidation'), super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<MaterialRequestBlocState> mapEventToState(
      MaterialRequestEvent event) async* {
    if (event is AddMaterialRequestEvent) {
      yield LoadingState();

      final productionOrderId = event.materialRequest.productionOrderId;
      final tanggalPermintaan = event.materialRequest.tanggalPermintaan;
      final materials = event.materialRequest.detailMaterialRequestList;
      final catatan = event.materialRequest.catatan;

      if(productionOrderId.isNotEmpty){
      try {
        final HttpsCallableResult<dynamic> result = await materialReqValidationCallable.call(<String, dynamic>{
          'materials': materials.map((material) => material.toJson()).toList(),
        });

        if (result.data['success'] == true) {
          final nextMaterialRequestId = await _generateNextMaterialRequestId();
          final materialRequestRef = _firestore.collection('material_requests').doc(nextMaterialRequestId);

          final Map<String, dynamic> materialRequestData = {
            'id': nextMaterialRequestId,
            'production_order_id': productionOrderId,
            'status': event.materialRequest.status,
            'status_mr': event.materialRequest.statusMr,
            'catatan': catatan,
            'tanggal_permintaan': tanggalPermintaan,
          };

          await materialRequestRef.set(materialRequestData);

          final detailMaterialRequestRef =
              materialRequestRef.collection('detail_material_requests');

          if (event.materialRequest.detailMaterialRequestList.isNotEmpty) {
            int detailCount = 1;
            for (var detailMaterialRequest
                in event.materialRequest.detailMaterialRequestList) {
              final nextDetailMaterialRequestId =
                  '$nextMaterialRequestId${'D${detailCount.toString().padLeft(3, '0')}'}';

            await detailMaterialRequestRef.add({
                'id': nextDetailMaterialRequestId,
                'material_request_id': nextMaterialRequestId,
                'jumlah_bom': detailMaterialRequest.jumlahBom,
                'material_id': detailMaterialRequest.materialId,
                'satuan': detailMaterialRequest.satuan,
                'batch': detailMaterialRequest.batch,
                'status': detailMaterialRequest.status,
              });
              detailCount++;
            }
          }

          await notificationService.addNotification('Terdapat permintaan bahan baru $nextMaterialRequestId', 'Gudang');
        
          yield SuccessState();
        }else{
          yield ErrorState(result.data['message']);
        }
      } catch (e) {
        yield ErrorState(e.toString());
      }
      }else{
        yield ErrorState("kode perintah produksi tidak boleh kosong");
      }
    } else if (event is UpdateMaterialRequestEvent) {
      yield LoadingState();

      final productionOrderId = event.materialRequest.productionOrderId;
      final tanggalPermintaan = event.materialRequest.tanggalPermintaan;
      final materials = event.materialRequest.detailMaterialRequestList;
      final catatan = event.materialRequest.catatan;

      if(productionOrderId.isNotEmpty){
      try {
        final HttpsCallableResult<dynamic> result = await materialReqValidationCallable.call(<String, dynamic>{
        'materials': materials.map((material) => material.toJson()).toList(),
        });

        if (result.data['success'] == true) {
           // Get a reference to the material request document to be updated
        final materialRequestToUpdateRef =
            _firestore.collection('material_requests').doc(event.materialRequestId);

        // Set the new material request data
        final Map<String, dynamic> materialRequestData = {
          'id': event.materialRequestId,
          'production_order_id': productionOrderId,
          'status': event.materialRequest.status,
          'status_mr': event.materialRequest.statusMr,
          'catatan': catatan,
          'tanggal_permintaan': tanggalPermintaan,
        };

        // Update the material request data within the existing document
        await materialRequestToUpdateRef.set(materialRequestData);

        // Delete all documents within the 'detail_material_requests' subcollection first
        final detailMaterialRequestCollectionRef =
            materialRequestToUpdateRef.collection('detail_material_requests');
        final detailMaterialRequestDocs =
            await detailMaterialRequestCollectionRef.get();
        for (var doc in detailMaterialRequestDocs.docs) {
          await doc.reference.delete();
        }

        // Add the new detail material request documents to the 'detail_material_requests' subcollection
        if (event.materialRequest.detailMaterialRequestList.isNotEmpty) {
          int detailCount = 1;
          for (var detailMaterialRequest
              in event.materialRequest.detailMaterialRequestList) {
            final nextDetailMaterialRequestId =
                'D${detailCount.toString().padLeft(3, '0')}';
            final detailId = event.materialRequestId + nextDetailMaterialRequestId;

            // Add the detail material request documents to the 'detail_material_requests' collection
            await detailMaterialRequestCollectionRef.add({
              'id': detailId,
              'material_request_id': event.materialRequestId,
              'jumlah_bom': detailMaterialRequest.jumlahBom,
              'material_id': detailMaterialRequest.materialId,
              'satuan': detailMaterialRequest.satuan,
              'batch' : detailMaterialRequest.batch,
              'status': detailMaterialRequest.status,
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
        yield ErrorState("nomor perintah produksi tidak boleh kosong");
      }
    } else if (event is DeleteMaterialRequestEvent) {
      yield LoadingState();
      try {
        // Get a reference to the material request document to be deleted
        final materialRequestToDeleteRef =
            _firestore.collection('material_requests').doc(event.materialRequestId);

        // Get a reference to the 'detail_material_requests' subcollection within the material request document
        final detailMaterialRequestCollectionRef =
            materialRequestToDeleteRef.collection('detail_material_requests');

        // Delete all documents within the 'detail_material_requests' subcollection
        final detailMaterialRequestDocs =
            await detailMaterialRequestCollectionRef.get();
        for (var doc in detailMaterialRequestDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents within the subcollection, delete the material request document itself
        await materialRequestToDeleteRef.delete();

        yield MaterialRequestDeletedState();
      } catch (e) {
        yield ErrorState("Failed to delete Material Request.");
      }
    }
  }

  Future<String> _generateNextMaterialRequestId() async {
    final materialRequestsRef =
        _firestore.collection('material_requests');
    final QuerySnapshot snapshot = await materialRequestsRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int materialRequestCount = 1;

    while (true) {
      final nextMaterialRequestId =
          'MR${materialRequestCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextMaterialRequestId)) {
        return nextMaterialRequestId;
      }
      materialRequestCount++;
    }
  }
}
