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

// States
abstract class MaterialReturnBlocState {}

class LoadingState extends MaterialReturnBlocState {}

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

  MaterialReturnBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<MaterialReturnBlocState> mapEventToState(
      MaterialReturnEvent event) async* {
    if (event is AddMaterialReturnEvent) {
      yield LoadingState();
      try {
        // Generate a new material return ID (or use an existing one if you have it)
        final nextMaterialReturnId = await _generateNextMaterialReturnId();

        // Create a reference to the material return document using the appropriate ID
        final materialReturnRef =
            _firestore.collection('material_returns').doc(nextMaterialReturnId);

        // Set the material return data
        final Map<String, dynamic> materialReturnData = {
          'id': nextMaterialReturnId,
          'material_usage_id': event.materialReturn.materialUsageId,
          'catatan': event.materialReturn.catatan,
          'status': event.materialReturn.status,
          'status_mrt': event.materialReturn.statusMrt,
          'tanggal_pengembalian':
              event.materialReturn.tanggalPengembalian.toUtc().toIso8601String(),
          'detail_material_return':
              event.materialReturn.detailMaterialReturn
                  .map((detail) => detail.toJson())
                  .toList(),
        };

        // Add the material return data to Firestore
        await materialReturnRef.set(materialReturnData);

        yield LoadedState(event.materialReturn);
      } catch (e) {
        yield ErrorState("Failed to add Material Return.");
      }
    } else if (event is UpdateMaterialReturnEvent) {
      yield LoadingState();
      try {
        // Get a reference to the material return document to be updated
        final materialReturnToUpdateRef = _firestore
            .collection('material_returns')
            .doc(event.materialReturnId);

        // Set the new material return data
        final Map<String, dynamic> materialReturnData = {
          'id': event.materialReturnId,
          'material_usage_id': event.materialReturn.materialUsageId,
          'catatan': event.materialReturn.catatan,
          'status': event.materialReturn.status,
          'status_mrt': event.materialReturn.statusMrt,
          'tanggal_pengembalian':
              event.materialReturn.tanggalPengembalian.toUtc().toIso8601String(),
          'detail_material_return':
              event.materialReturn.detailMaterialReturn
                  .map((detail) => detail.toJson())
                  .toList(),
        };

        // Update the material return data within the existing document
        await materialReturnToUpdateRef.set(materialReturnData);

        yield MaterialReturnUpdatedState();
      } catch (e) {
        yield ErrorState("Failed to update Material Return.");
      }
    } else if (event is DeleteMaterialReturnEvent) {
      yield LoadingState();
      try {
        // Get a reference to the material return document to be deleted
        final materialReturnToDeleteRef = _firestore
            .collection('material_returns')
            .doc(event.materialReturnId);

        // Delete the material return document
        await materialReturnToDeleteRef.delete();

        yield MaterialReturnDeletedState();
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
