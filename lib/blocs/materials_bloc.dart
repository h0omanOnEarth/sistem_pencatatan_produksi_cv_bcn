import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/material.dart';

// Events
abstract class MaterialEvent {}

class AddMaterialEvent extends MaterialEvent {
  final Bahan material;
  AddMaterialEvent(this.material);
}

class UpdateMaterialEvent extends MaterialEvent {
  final String materialId;
  final Bahan updatedMaterial;
  UpdateMaterialEvent(this.materialId, this.updatedMaterial);
}

class DeleteMaterialEvent extends MaterialEvent {
  final String materialId;
  DeleteMaterialEvent(this.materialId);
}

// States
abstract class MaterialBlocState {}

class LoadingState extends MaterialBlocState {}

class LoadedState extends MaterialBlocState {
  final List<Bahan> materials;
  LoadedState(this.materials);
}

class ErrorState extends MaterialBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class MaterialBloc extends Bloc<MaterialEvent, MaterialBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference materialsRef;

  MaterialBloc() : super(LoadingState()){
    _firestore = FirebaseFirestore.instance;
    materialsRef = _firestore.collection('materials');
  }

  @override
  Stream<MaterialBlocState> mapEventToState(MaterialEvent event) async* {
    if (event is AddMaterialEvent) {
      yield LoadingState();
      try {
        final String nextMaterialId = await _generateNextMaterialId();

        await FirebaseFirestore.instance.collection('materials').add({
          'id': nextMaterialId,
          'jenis_bahan': event.material.jenisBahan,
          'keterangan': event.material.keterangan,
          'nama': event.material.nama,
          'satuan': event.material.satuan,
          'status': event.material.status,
          'stok': event.material.stok,
        });

        yield LoadedState(await _getMaterials());
      } catch (e) {
        yield ErrorState("Gagal menambahkan material.");
      }
    } else if (event is UpdateMaterialEvent) {
      yield LoadingState();
      try {
        await materialsRef.doc(event.materialId).update({
          'jenis_bahan': event.updatedMaterial.jenisBahan,
          'keterangan': event.updatedMaterial.keterangan,
          'nama': event.updatedMaterial.nama,
          'satuan': event.updatedMaterial.satuan,
          'status': event.updatedMaterial.status,
          'stok': event.updatedMaterial.stok,
        });

        yield LoadedState(await _getMaterials());
      } catch (e) {
        yield ErrorState("Gagal mengubah material.");
      }
    } else if (event is DeleteMaterialEvent) {
      yield LoadingState();
      try {
        await materialsRef.doc(event.materialId).delete();
        yield LoadedState(await _getMaterials());
      } catch (e) {
        yield ErrorState("Gagal menghapus material.");
      }
    }
  }

  Future<String> _generateNextMaterialId() async {
    final QuerySnapshot snapshot = await materialsRef.get();
    final int materialCount = snapshot.docs.length;
    final String nextMaterialId =
        'material${(materialCount + 1).toString().padLeft(3, '0')}';
    return nextMaterialId;
  }

  Future<List<Bahan>> _getMaterials() async {
    final QuerySnapshot snapshot = await materialsRef.get();
    final List<Bahan> materials = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      materials.add(Bahan.fromJson(data));
    }
    return materials;
  }
}
