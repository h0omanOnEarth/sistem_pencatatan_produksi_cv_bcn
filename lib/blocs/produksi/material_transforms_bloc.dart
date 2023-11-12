import 'package:cloud_functions/cloud_functions.dart';
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
  UpdateMaterialTransformsEvent(
      this.materialTransformsId, this.updatedMaterialTransforms);
}

class DeleteMaterialTransformsEvent extends MaterialTransformsEvent {
  final String materialTransformsId;
  DeleteMaterialTransformsEvent(this.materialTransformsId);
}

class FinishedMaterialTransformsEvent extends MaterialTransformsEvent {
  final String materialTransformsId;
  FinishedMaterialTransformsEvent(this.materialTransformsId);
}

// States
abstract class MaterialTransformsBlocState {}

class LoadingState extends MaterialTransformsBlocState {}

class SuccessState extends MaterialTransformsBlocState {}

class LoadedState extends MaterialTransformsBlocState {
  final List<MaterialTransforms> materialTransformsList;
  LoadedState(this.materialTransformsList);
}

class ErrorState extends MaterialTransformsBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class MaterialTransformsBloc
    extends Bloc<MaterialTransformsEvent, MaterialTransformsBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference materialTransformsRef;
  final HttpsCallable materialTransformCallable;

  MaterialTransformsBloc()
      : materialTransformCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('materialTransformValidate'),
        super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    materialTransformsRef = _firestore.collection('material_transforms');
  }

  @override
  Stream<MaterialTransformsBlocState> mapEventToState(
      MaterialTransformsEvent event) async* {
    if (event is AddMaterialTransformsEvent) {
      yield LoadingState();

      final satuanHasil = event.materialTransforms.satuanHasil;
      final satuanTotalHasil = event.materialTransforms.satuanTotalHasil;
      final machineId = event.materialTransforms.machineId;
      final jumlahBarangGagal = event.materialTransforms.jumlahBarangGagal;
      final jumlahHasil = event.materialTransforms.jumlahHasil;
      final totalHasil = event.materialTransforms.totalHasil;

      if (machineId.isNotEmpty) {
        if (satuanHasil.isNotEmpty && satuanTotalHasil.isNotEmpty) {
          try {
            final HttpsCallableResult<dynamic> result =
                await materialTransformCallable.call(<String, dynamic>{
              'jumlahBarangGagal': jumlahBarangGagal,
              'jumlahHasil': jumlahHasil,
              'totalHasil': totalHasil
            });

            if (result.data['success'] == true) {
              final String nextMaterialTransformsId =
                  await _generateNextMaterialTransformsId();
              final materialTransformsRef = _firestore
                  .collection('material_transforms')
                  .doc(nextMaterialTransformsId);

              final Map<String, dynamic> materialTransformsData = {
                'id': nextMaterialTransformsId,
                'catatan': event.materialTransforms.catatan,
                'jumlah_barang_gagal':
                    event.materialTransforms.jumlahBarangGagal,
                'jumlah_hasil': event.materialTransforms.jumlahHasil,
                'machine_id': event.materialTransforms.machineId,
                'satuan': event.materialTransforms.satuan,
                'satuan_hasil': event.materialTransforms.satuanHasil,
                'satuan_total_hasil': event.materialTransforms.satuanTotalHasil,
                'status': event.materialTransforms.status,
                'status_mtf': event.materialTransforms.statusMtf,
                'tanggal_pengubahan':
                    event.materialTransforms.tanggalPengubahan,
                'total_hasil': event.materialTransforms.totalHasil,
              };

              await materialTransformsRef.set(materialTransformsData);

              yield SuccessState();
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState("satuan tidak boleh kosong");
        }
      } else {
        yield ErrorState("kode mesin tidak boleh kosong");
      }
    } else if (event is UpdateMaterialTransformsEvent) {
      yield LoadingState();

      final satuanHasil = event.updatedMaterialTransforms.satuanHasil;
      final satuanTotalHasil = event.updatedMaterialTransforms.satuanTotalHasil;
      final machineId = event.updatedMaterialTransforms.machineId;
      final jumlahBarangGagal =
          event.updatedMaterialTransforms.jumlahBarangGagal;
      final jumlahHasil = event.updatedMaterialTransforms.jumlahHasil;
      final totalHasil = event.updatedMaterialTransforms.totalHasil;

      if (machineId.isNotEmpty) {
        if (satuanHasil.isNotEmpty && satuanTotalHasil.isNotEmpty) {
          try {
            final HttpsCallableResult<dynamic> result =
                await materialTransformCallable.call(<String, dynamic>{
              'jumlahBarangGagal': jumlahBarangGagal,
              'jumlahHasil': jumlahHasil,
              'totalHasil': totalHasil
            });

            if (result.data['success'] == true) {
              final materialTransformsSnapshot = await materialTransformsRef
                  .where('id', isEqualTo: event.materialTransformsId)
                  .get();
              if (materialTransformsSnapshot.docs.isNotEmpty) {
                final materialTransformsDoc =
                    materialTransformsSnapshot.docs.first;
                await materialTransformsDoc.reference.update({
                  'catatan': event.updatedMaterialTransforms.catatan,
                  'jumlah_barang_gagal':
                      event.updatedMaterialTransforms.jumlahBarangGagal,
                  'jumlah_hasil': event.updatedMaterialTransforms.jumlahHasil,
                  'machine_id': event.updatedMaterialTransforms.machineId,
                  'satuan': event.updatedMaterialTransforms.satuan,
                  'satuan_hasil': event.updatedMaterialTransforms.satuanHasil,
                  'satuan_total_hasil':
                      event.updatedMaterialTransforms.satuanTotalHasil,
                  'status': event.updatedMaterialTransforms.status,
                  'status_mtf': event.updatedMaterialTransforms.statusMtf,
                  'tanggal_pengubahan':
                      event.updatedMaterialTransforms.tanggalPengubahan,
                  'total_hasil': event.updatedMaterialTransforms.totalHasil,
                });
                yield SuccessState();
              } else {
                yield ErrorState(
                    'Material Transforms with ID ${event.materialTransformsId} not found.');
              }
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState("satuan tidak boleh kosong");
        }
      } else {
        yield ErrorState("kode mesin tidak boleh kosong");
      }
    } else if (event is DeleteMaterialTransformsEvent) {
      yield LoadingState();
      try {
        final QuerySnapshot querySnapshot = await materialTransformsRef
            .where('id', isEqualTo: event.materialTransformsId)
            .get();

        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          // Perbarui status menjadi 0
          await documentSnapshot.reference.update({'status': 0});

          final materialTransformData =
              documentSnapshot.data() as Map<String, dynamic>;
          final jumlahBarangGagal =
              materialTransformData['jumlah_barang_gagal'] as int;
          final jumlahHasil = materialTransformData['jumlah_hasil'] as int;

          // Update stok di koleksi 'products'
          final productRef = _firestore
              .collection('products')
              .where('id', isEqualTo: 'productXXX');
          final productQuerySnapshot = await productRef.get();
          for (QueryDocumentSnapshot productDocument
              in productQuerySnapshot.docs) {
            final currentStock = productDocument['stok'] as int;
            final newStock = currentStock + jumlahBarangGagal;
            productDocument.reference.update({'stok': newStock});
          }

          // Kurangi stok di koleksi 'materials'
          final materialRef = _firestore
              .collection('materials')
              .where('id', isEqualTo: 'materialXXX');
          final materialQuerySnapshot = await materialRef.get();
          for (QueryDocumentSnapshot materialDocument
              in materialQuerySnapshot.docs) {
            final currentStock = materialDocument['stok'] as int;
            final newStock = currentStock - jumlahHasil;
            materialDocument.reference.update({'stok': newStock});
          }
        }

        yield SuccessState();
      } catch (e) {
        yield ErrorState("Failed to delete Material Transforms.");
      }
    } else if (event is FinishedMaterialTransformsEvent) {
      yield LoadingState();
      try {
        final materialTransformRef = _firestore
            .collection('material_transforms')
            .doc(event.materialTransformsId);

        await materialTransformRef.update({
          'status_mtf': 'Selesai',
        });

        yield SuccessState();
      } catch (e) {
        yield ErrorState("Failed to finish Material Transform");
      }
    }
  }

  Future<String> _generateNextMaterialTransformsId() async {
    final QuerySnapshot snapshot = await materialTransformsRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int materialTransformsCount = 1;

    while (true) {
      final nextMaterialTransformsId =
          'MTF${materialTransformsCount.toString().padLeft(5, '0')}';
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
