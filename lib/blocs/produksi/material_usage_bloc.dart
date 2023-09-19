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

// States
abstract class MaterialUsageBlocState {}

class LoadingState extends MaterialUsageBlocState {}

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

  MaterialUsageBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<MaterialUsageBlocState> mapEventToState(
      MaterialUsageEvent event) async* {
    if (event is AddMaterialUsageEvent) {
      yield LoadingState();
      try {
        // Generate a new material usage ID (or use an existing one if you have it)
        final nextMaterialUsageId = await _generateNextMaterialUsageId();

        // Create a reference to the material usage document using the appropriate ID
        final materialUsageRef =
            _firestore.collection('material_usages').doc(nextMaterialUsageId);

        // Set the material usage data
        final Map<String, dynamic> materialUsageData = {
          'id': nextMaterialUsageId,
          'batch': event.materialUsage.batch,
          'catatan': event.materialUsage.catatan,
          'production_order_id': event.materialUsage.productionOrderId,
          'status': event.materialUsage.status,
          'status_mu': event.materialUsage.statusMu,
          'tanggal_penggunaan': event.materialUsage.tanggalPenggunaan,
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

        yield LoadedState(event.materialUsage);
      } catch (e) {
        yield ErrorState("Failed to add Material Usage.");
      }
    } else if (event is UpdateMaterialUsageEvent) {
      yield LoadingState();
      try {
        // Get a reference to the material usage document to be updated
        final materialUsageToUpdateRef =
            _firestore.collection('material_usages').doc(event.materialUsageId);

        // Set the new material usage data
        final Map<String, dynamic> materialUsageData = {
          'id': event.materialUsageId,
          'batch': event.materialUsage.batch,
          'catatan': event.materialUsage.catatan,
          'production_order_id': event.materialUsage.productionOrderId,
          'status': event.materialUsage.status,
          'status_mu': event.materialUsage.statusMu,
          'tanggal_penggunaan': event.materialUsage.tanggalPenggunaan,
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

        yield MaterialUsageUpdatedState();
      } catch (e) {
        yield ErrorState("Failed to update Material Usage.");
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
