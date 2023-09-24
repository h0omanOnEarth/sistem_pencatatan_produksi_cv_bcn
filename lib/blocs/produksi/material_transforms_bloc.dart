import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_transform.dart';

// Events
abstract class MaterialTransformsEvent {}

class AddMaterialTransformsEvent extends MaterialTransformsEvent {
  final MaterialTransforms materialTransforms;
  AddMaterialTransformsEvent(this.materialTransforms);
}

class UpdateMaterialTransformsEvent extends MaterialTransformsEvent {
  final String materialTransformsId;
  final MaterialTransforms updatedMaterialTransforms;
  UpdateMaterialTransformsEvent(this.materialTransformsId, this.updatedMaterialTransforms);
}

class DeleteMaterialTransformsEvent extends MaterialTransformsEvent {
  final String materialTransformsId;
  DeleteMaterialTransformsEvent(this.materialTransformsId);
}

// States
abstract class MaterialTransformsBlocState {}

class LoadingState extends MaterialTransformsBlocState {}

class LoadedState extends MaterialTransformsBlocState {
  final List<MaterialTransforms> materialTransformsList;
  LoadedState(this.materialTransformsList);
}

class ErrorState extends MaterialTransformsBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class MaterialTransformsBloc extends Bloc<MaterialTransformsEvent, MaterialTransformsBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference materialTransformsRef;

  MaterialTransformsBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    materialTransformsRef = _firestore.collection('material_transforms');
  }

  @override
  Stream<MaterialTransformsBlocState> mapEventToState(MaterialTransformsEvent event) async* {
    if (event is AddMaterialTransformsEvent) {
      yield LoadingState();
      try {
        final String nextMaterialTransformsId = await _generateNextMaterialTransformsId();
        final materialTransformsRef = _firestore.collection('material_transforms').doc(nextMaterialTransformsId);

        final Map<String, dynamic> materialTransformsData = {
          'id': nextMaterialTransformsId,
          'catatan': event.materialTransforms.catatan,
          'jumlah_barang_gagal': event.materialTransforms.jumlahBarangGagal,
          'jumlah_hasil': event.materialTransforms.jumlahHasil,
          'machine_id': event.materialTransforms.machineId,
          'satuan': event.materialTransforms.satuan,
          'satuan_hasil': event.materialTransforms.satuanHasil,
          'satuan_total_hasil': event.materialTransforms.satuanTotalHasil,
          'status': event.materialTransforms.status,
          'status_mtf': event.materialTransforms.statusMtf,
          'tanggal_pengubahan': event.materialTransforms.tanggalPengubahan,
          'total_hasil': event.materialTransforms.totalHasil,
        };

        await materialTransformsRef.set(materialTransformsData);

        final materialTransformsList = await _getMaterialTransformsList();
        yield LoadedState(materialTransformsList);
      } catch (e) {
        yield ErrorState("Failed to add Material Transforms.");
      }
    } else if (event is UpdateMaterialTransformsEvent) {
      yield LoadingState();
      try {
        final materialTransformsSnapshot = await materialTransformsRef.where('id', isEqualTo: event.materialTransformsId).get();
        if (materialTransformsSnapshot.docs.isNotEmpty) {
          final materialTransformsDoc = materialTransformsSnapshot.docs.first;
          await materialTransformsDoc.reference.update({
            'catatan': event.updatedMaterialTransforms.catatan,
            'jumlah_barang_gagal': event.updatedMaterialTransforms.jumlahBarangGagal,
            'jumlah_hasil': event.updatedMaterialTransforms.jumlahHasil,
            'machine_id': event.updatedMaterialTransforms.machineId,
            'satuan': event.updatedMaterialTransforms.satuan,
            'satuan_hasil': event.updatedMaterialTransforms.satuanHasil,
            'satuan_total_hasil': event.updatedMaterialTransforms.satuanTotalHasil,
            'status': event.updatedMaterialTransforms.status,
            'status_mtf': event.updatedMaterialTransforms.statusMtf,
            'tanggal_pengubahan': event.updatedMaterialTransforms.tanggalPengubahan,
            'total_hasil': event.updatedMaterialTransforms.totalHasil,
          });
          final materialTransformsList = await _getMaterialTransformsList();
          yield LoadedState(materialTransformsList);
        } else {
          yield ErrorState('Material Transforms with ID ${event.materialTransformsId} not found.');
        }
      } catch (e) {
        yield ErrorState("Failed to update Material Transforms.");
      }
    } else if (event is DeleteMaterialTransformsEvent) {
      yield LoadingState();
      try {
        final QuerySnapshot querySnapshot = await materialTransformsRef.where('id', isEqualTo: event.materialTransformsId).get();
          
        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          await documentSnapshot.reference.delete();
        }
        final materialTransformsList = await _getMaterialTransformsList();
        yield LoadedState(materialTransformsList);
      } catch (e) {
        yield ErrorState("Failed to delete Material Transforms.");
      }
    }
  }

  Future<String> _generateNextMaterialTransformsId() async {
    final QuerySnapshot snapshot = await materialTransformsRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int materialTransformsCount = 1;

    while (true) {
      final nextMaterialTransformsId = 'MTF${materialTransformsCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextMaterialTransformsId)) {
        return nextMaterialTransformsId;
      }
      materialTransformsCount++;
    }
  }

  Future<List<MaterialTransforms>> _getMaterialTransformsList() async {
    final QuerySnapshot snapshot = await materialTransformsRef.get();
    final List<MaterialTransforms> materialTransformsList = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      materialTransformsList.add(MaterialTransforms.fromJson(data));
    }
    return materialTransformsList;
  }
}
