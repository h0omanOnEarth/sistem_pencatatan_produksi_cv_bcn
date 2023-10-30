import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/material.dart';

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

class SuccessState extends MaterialBlocState {}

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

  MaterialBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    materialsRef = _firestore.collection('materials');
  }

  @override
  Stream<MaterialBlocState> mapEventToState(MaterialEvent event) async* {
    if (event is AddMaterialEvent) {
      yield LoadingState();

      final jenisBahan = event.material.jenisBahan;
      final keterangan = event.material.keterangan;
      final nama = event.material.nama;
      final satuan = event.material.satuan;
      final status = event.material.status;
      final stok = event.material.stok;

      if (nama.isNotEmpty) {
        try {
          final HttpsCallable callable =
              FirebaseFunctions.instanceFor(region: "asia-southeast2")
                  .httpsCallable('materialModif');
          final HttpsCallableResult<dynamic> result =
              await callable.call(<String, dynamic>{
            'stok': stok,
          });

          if (result.data['success'] == true) {
            final String nextMaterialId = await _generateNextMaterialId();

            await FirebaseFirestore.instance.collection('materials').add({
              'id': nextMaterialId,
              'jenis_bahan': jenisBahan,
              'keterangan': keterangan,
              'nama': nama,
              'satuan': satuan,
              'status': status,
              'stok': stok,
            });

            yield SuccessState();
          } else {
            yield ErrorState(result.data['message']);
          }
        } catch (e) {
          yield ErrorState(e.toString());
        }
      } else {
        yield ErrorState('nama tidak boleh kosong');
      }
    } else if (event is UpdateMaterialEvent) {
      yield LoadingState();
      final materialSnapshot =
          await materialsRef.where('id', isEqualTo: event.materialId).get();
      if (materialSnapshot.docs.isNotEmpty) {
        final jenisBahan = event.updatedMaterial.jenisBahan;
        final keterangan = event.updatedMaterial.keterangan;
        final nama = event.updatedMaterial.nama;
        final satuan = event.updatedMaterial.satuan;
        final status = event.updatedMaterial.status;
        final stok = event.updatedMaterial.stok;

        if (nama.isNotEmpty) {
          try {
            final HttpsCallable callable =
                FirebaseFunctions.instanceFor(region: "asia-southeast2")
                    .httpsCallable('materialModif');
            final HttpsCallableResult<dynamic> result =
                await callable.call(<String, dynamic>{
              'stok': stok,
            });

            if (result.data['success'] == true) {
              final materialDoc = materialSnapshot.docs.first;
              await materialDoc.reference.update({
                'jenis_bahan': jenisBahan,
                'keterangan': keterangan,
                'nama': nama,
                'satuan': satuan,
                'status': status,
                'stok': stok,
              });

              yield SuccessState();
            } else {
              yield ErrorState(result.data['success']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState("nama tidak boleh kosong");
        }
      } else {
        // Handle jika data pelanggan dengan ID tersebut tidak ditemukan
        yield ErrorState(
            'Data bahan dengan ID ${event.materialId} tidak ditemukan.');
      }
    } else if (event is DeleteMaterialEvent) {
      yield LoadingState();
      try {
        // Cari dokumen dengan 'id' yang sesuai dengan event.materialId
        QuerySnapshot querySnapshot =
            await materialsRef.where('id', isEqualTo: event.materialId).get();

        // Perbarui status menjadi 0 (tidak aktif) pada semua dokumen yang sesuai
        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          await documentSnapshot.reference.update({'status': 0});
        }
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
