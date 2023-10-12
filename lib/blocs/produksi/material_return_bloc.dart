import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_return.dart';

// Events
abstract class MaterialReturnEvent {}

class AddMaterialReturnEvent extends MaterialReturnEvent {
  final MaterialReturn materialReturn;
  AddMaterialReturnEvent(this.materialReturn);
}

class UpdateMaterialReturnEvent extends MaterialReturnEvent {
  final String materialReturnId;
  final MaterialReturn materialReturn;
  UpdateMaterialReturnEvent(this.materialReturnId, this.materialReturn);
}

class DeleteMaterialReturnEvent extends MaterialReturnEvent {
  final String materialReturnId;
  DeleteMaterialReturnEvent(this.materialReturnId);
}

class FinishedMaterialReturnEvent extends MaterialReturnEvent {
  final String materialReturnId;
  FinishedMaterialReturnEvent(this.materialReturnId);
}

// States
abstract class MaterialReturnBlocState {}

class LoadingState extends MaterialReturnBlocState {}

class SuccessState extends MaterialReturnBlocState {}

class LoadedState extends MaterialReturnBlocState {
  final MaterialReturn materialReturn;
  LoadedState(this.materialReturn);
}

class MaterialReturnUpdatedState extends MaterialReturnBlocState {}

class MaterialReturnDeletedState extends MaterialReturnBlocState {}

class ErrorState extends MaterialReturnBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class MaterialReturnBloc
    extends Bloc<MaterialReturnEvent, MaterialReturnBlocState> {
  late FirebaseFirestore _firestore;
  final HttpsCallable materialRetValidationCallable;

  MaterialReturnBloc() : materialRetValidationCallable = FirebaseFunctions.instance.httpsCallable('materialReturnValidation'), super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<MaterialReturnBlocState> mapEventToState(
      MaterialReturnEvent event) async* {
    if (event is AddMaterialReturnEvent) {
      yield LoadingState();

      final materialUsageId = event.materialReturn.materialUsageId;
      final catatan = event.materialReturn.catatan;
      final tanggalPengembalian = event.materialReturn.tanggalPengembalian;
      final materials = event.materialReturn.detailMaterialReturn;

      if(materialUsageId.isNotEmpty){
      try {
       final HttpsCallableResult<dynamic> result = await materialRetValidationCallable.call(<String, dynamic>{
        'materials': materials.map((material) => material.toJson()).toList(),
        'materialUsageId': materialUsageId,
        'mode': 'add'
      });

      if (result.data['success'] == true) {
         // Generate a new material return ID (or use an existing one if you have it)
        final nextMaterialReturnId = await _generateNextMaterialReturnId();

        // Create a reference to the material return document using the appropriate ID
        final materialReturnRef =
            _firestore.collection('material_returns').doc(nextMaterialReturnId);

        // Set the material return data
        final Map<String, dynamic> materialReturnData = {
          'id': nextMaterialReturnId,
          'material_usage_id': materialUsageId,
          'catatan': catatan,
          'status': event.materialReturn.status,
          'status_mrt': event.materialReturn.statusMrt,
          'tanggal_pengembalian': tanggalPengembalian,
        };

        // Add the material return data to Firestore
        await materialReturnRef.set(materialReturnData);

        final materialReturnDetailsRef = materialReturnRef.collection('detail_material_returns');

        if (event.materialReturn.detailMaterialReturn.isNotEmpty) {
          int detailCount = 1;
          for (var detailMaterialReturn
              in event.materialReturn.detailMaterialReturn) {
            final nextDetailMaterialReturnId =
                '$nextMaterialReturnId${'D${detailCount.toString().padLeft(3, '0')}'}';

            await materialReturnDetailsRef.add({
              'id': nextDetailMaterialReturnId,
              'material_return_id': nextMaterialReturnId,
              'jumlah': detailMaterialReturn.jumlah,
              'material_id': detailMaterialReturn.materialId,
              'satuan': detailMaterialReturn.satuan,
              'status': detailMaterialReturn.status,
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
        yield ErrorState("nomor penggunaan bahan tidak boleh kosong,\n pengembalian bisa dilakukan jika sudah menggunakan");
      }

    } else if (event is UpdateMaterialReturnEvent) {
      yield LoadingState();

      final materialUsageId = event.materialReturn.materialUsageId;
      final catatan = event.materialReturn.catatan;
      final tanggalPengembalian = event.materialReturn.tanggalPengembalian;
      final materials = event.materialReturn.detailMaterialReturn;

      try {
      final HttpsCallableResult<dynamic> result = await materialRetValidationCallable.call(<String, dynamic>{
      'materials': materials.map((material) => material.toJson()).toList(),
      'materialUsageId': materialUsageId,
      'mode': 'edit'
      });

      if (result.data['success'] == true) {
         // Get a reference to the material return document to be updated
        final materialReturnToUpdateRef =
            _firestore.collection('material_returns').doc(event.materialReturnId);

        // Set the new material return data
        final Map<String, dynamic> materialReturnData = {
          'id': event.materialReturnId,
          'material_usage_id': materialUsageId,
          'catatan': catatan,
          'status': event.materialReturn.status,
          'status_mrt': event.materialReturn.statusMrt,
          'tanggal_pengembalian': tanggalPengembalian,
        };

        // Update the material return data within the existing document
        await materialReturnToUpdateRef.set(materialReturnData);

        final materialReturnDetailsCollectionRef =
            materialReturnToUpdateRef.collection('detail_material_returns');
        final materialReturnDetailsDocs =
            await materialReturnDetailsCollectionRef.get();
        for (var doc in materialReturnDetailsDocs.docs) {
          await doc.reference.delete();
        }

        if (event.materialReturn.detailMaterialReturn.isNotEmpty) {
          int detailCount = 1;
          for (var detailMaterialReturn
              in event.materialReturn.detailMaterialReturn) {
            final nextDetailMaterialReturnId =
                'D${detailCount.toString().padLeft(3, '0')}';
            final detailId = event.materialReturnId + nextDetailMaterialReturnId;

            await materialReturnDetailsCollectionRef.add({
              'id': detailId,
              'material_return_id': event.materialReturnId,
              'jumlah': detailMaterialReturn.jumlah,
              'material_id': detailMaterialReturn.materialId,
              'satuan': detailMaterialReturn.satuan,
              'status': detailMaterialReturn.status,
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
    } else if (event is DeleteMaterialReturnEvent) {
      yield LoadingState();
      try {
        // Get a reference to the material return document to be deleted
        final materialReturnToDeleteRef =
            _firestore.collection('material_returns').doc(event.materialReturnId);

        final materialReturnDetailsCollectionRef =
            materialReturnToDeleteRef.collection('detail_material_returns');

        final materialReturnDetailsDocs =
            await materialReturnDetailsCollectionRef.get();
        for (var doc in materialReturnDetailsDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents within the subcollection, delete the material return document itself
        await materialReturnToDeleteRef.delete();

        yield MaterialReturnDeletedState();
      } catch (e) {
        yield ErrorState("Failed to delete Material Return.");
      }
    }else if (event is FinishedMaterialReturnEvent) {
      yield LoadingState();
      try {
       
        final materialReturnRef = _firestore.collection('material_returns').doc(event.materialReturnId);

        await materialReturnRef.update({
          'status_mrt': 'Selesai',
        });

        yield SuccessState();
      } catch (e) {
        yield ErrorState("Failed to delete Material Return.");
      }
    } 
  }

 Future<String> _generateNextMaterialReturnId() async {
    final materialReturnsRef = _firestore.collection('material_returns');
    final QuerySnapshot snapshot = await materialReturnsRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int materialReturnCount = 1;

    while (true) {
      final nextMaterialReturnId =
          'MRT${materialReturnCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextMaterialReturnId)) {
        return nextMaterialReturnId;
      }
      materialReturnCount++;
    }
  }
}