import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/purchase_return.dart';

// Events
abstract class PurchaseReturnEvent {}

class AddPurchaseReturnEvent extends PurchaseReturnEvent {
  final PurchaseReturn purchaseReturn;
  AddPurchaseReturnEvent(this.purchaseReturn);
}

class UpdatePurchaseReturnEvent extends PurchaseReturnEvent {
  final String purchaseReturnId;
  final PurchaseReturn updatedPurchaseReturn;
  final int qtyLama;
  UpdatePurchaseReturnEvent(
      this.purchaseReturnId, this.updatedPurchaseReturn, this.qtyLama);
}

class DeletePurchaseReturnEvent extends PurchaseReturnEvent {
  final String purchaseReturnId;
  DeletePurchaseReturnEvent(this.purchaseReturnId);
}

// States
abstract class PurchaseReturnBlocState {}

class LoadingState extends PurchaseReturnBlocState {}

class SuccessState extends PurchaseReturnBlocState {}

class LoadedState extends PurchaseReturnBlocState {
  final List<PurchaseReturn> purchaseReturns;
  LoadedState(this.purchaseReturns);
}

class ErrorState extends PurchaseReturnBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class PurchaseReturnBloc
    extends Bloc<PurchaseReturnEvent, PurchaseReturnBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference purchaseReturnsRef;
  final HttpsCallable purchaseReturnCallable;

  PurchaseReturnBloc()
      : purchaseReturnCallable = FirebaseFunctions.instance
            .httpsCallable('purchaseReturnValidation'),
        super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    purchaseReturnsRef = _firestore.collection('purchase_returns');
  }

  @override
  Stream<PurchaseReturnBlocState> mapEventToState(
      PurchaseReturnEvent event) async* {
    if (event is AddPurchaseReturnEvent) {
      yield LoadingState();

      final purchaseOrderId = event.purchaseReturn.purchaseOrderId;
      final jumlah = event.purchaseReturn.jumlah;
      final satuan = event.purchaseReturn.satuan;
      final alamatPengembalian = event.purchaseReturn.alamatPengembalian;
      final alasan = event.purchaseReturn.alasan;
      final status = event.purchaseReturn.status;
      final tanggalPengembalian = event.purchaseReturn.tanggalPengembalian;
      final keterangan = event.purchaseReturn.keterangan;

      // Ambil 'material_id' dari Firestore berdasarkan 'purchaseOrderId'
      final materialId = await _getMaterialIdByPurchaseOrderId(
          event.purchaseReturn.purchaseOrderId);
      // Ambil 'jenis_bahan' dari Firestore berdasarkan 'material_id'
      final jenisBahan = await _getJenisBahanByMaterialId(materialId);

      if (purchaseOrderId.isNotEmpty &&
          satuan.isNotEmpty &&
          alamatPengembalian.isNotEmpty) {
        if (jumlah > 0) {
          try {
            final HttpsCallableResult<dynamic> result =
                await purchaseReturnCallable.call(<String, dynamic>{
              'jumlah': jumlah,
              'purchaseOrderId': purchaseOrderId,
              'satuan': satuan,
              'qtyLama': 0,
              'mode': 'add'
            });

            if (result.data['success'] == true) {
              final String nextPurchaseReturnId =
                  await _generateNextPurchaseReturnId();
              await FirebaseFirestore.instance
                  .collection('purchase_returns')
                  .add({
                'id': nextPurchaseReturnId,
                'purchase_order_id': purchaseOrderId,
                'jumlah': jumlah,
                'satuan': satuan,
                'alamat_pengembalian': alamatPengembalian,
                'alasan': alasan,
                'status': status,
                'tanggal_pengembalian': tanggalPengembalian,
                'jenis_bahan': jenisBahan,
                'keterangan': keterangan
              });

              yield SuccessState();
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState('jumlah harus diatas 0');
        }
      } else {
        yield ErrorState("data pengembalian bahan ada yang tidak lengkap");
      }
    } else if (event is UpdatePurchaseReturnEvent) {
      yield LoadingState();

      final purchaseReturnSnapshot = await purchaseReturnsRef
          .where('id', isEqualTo: event.purchaseReturnId)
          .get();
      if (purchaseReturnSnapshot.docs.isNotEmpty) {
        final purchaseOrderId = event.updatedPurchaseReturn.purchaseOrderId;
        final jumlah = event.updatedPurchaseReturn.jumlah;
        final satuan = event.updatedPurchaseReturn.satuan;
        final alamatPengembalian =
            event.updatedPurchaseReturn.alamatPengembalian;

        if (purchaseOrderId.isNotEmpty &&
            satuan.isNotEmpty &&
            alamatPengembalian.isNotEmpty) {
          if (jumlah > 0) {
            try {
              final HttpsCallableResult<dynamic> result =
                  await purchaseReturnCallable.call(<String, dynamic>{
                'jumlah': jumlah,
                'purchaseOrderId': purchaseOrderId,
                'satuan': satuan,
                'qtyLama': event.qtyLama,
                'mode': 'add'
              });

              if (result.data['success'] == true) {
                final purchaseReturnDoc = purchaseReturnSnapshot.docs.first;
                // Ambil 'material_id' dari Firestore berdasarkan 'purchaseOrderId'
                final materialId = await _getMaterialIdByPurchaseOrderId(
                    event.updatedPurchaseReturn.purchaseOrderId);
                // Ambil 'jenis_bahan' dari Firestore berdasarkan 'material_id'
                final jenisBahan = await _getJenisBahanByMaterialId(materialId);
                await purchaseReturnDoc.reference.update({
                  ...event.updatedPurchaseReturn.toJson(),
                  'id': event.purchaseReturnId,
                  'tanggal_pengembalian':
                      event.updatedPurchaseReturn.tanggalPengembalian,
                  'jenis_bahan': jenisBahan, // Set nilai jenis_bahan
                });

                yield SuccessState();
              } else {
                yield ErrorState(result.data['message']);
              }
            } catch (e) {
              yield ErrorState(e.toString());
            }
          } else {
            yield ErrorState('jumlah harus lebih besar dari 0');
          }
        } else {
          yield ErrorState('data pengembalian bahan tidak lengkap');
        }
      } else {
        yield ErrorState(
            'Purchase Return dengan ID ${event.purchaseReturnId} tidak ditemukan.');
      }
    } else if (event is DeletePurchaseReturnEvent) {
      yield LoadingState();
      try {
        final purchaseReturnSnapshot = await purchaseReturnsRef
            .where('id', isEqualTo: event.purchaseReturnId)
            .get();
        for (QueryDocumentSnapshot documentSnapshot
            in purchaseReturnSnapshot.docs) {
          await documentSnapshot.reference.delete();
        }
        yield LoadedState(await _getPurchaseReturns());
      } catch (e) {
        yield ErrorState("Gagal menghapus Purchase Return.");
      }
    }
  }

  Future<String> _generateNextPurchaseReturnId() async {
    final QuerySnapshot snapshot = await purchaseReturnsRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int purchaseReturnCount = 1;

    while (true) {
      final nextPurchaseReturnId =
          'PR${purchaseReturnCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextPurchaseReturnId)) {
        return nextPurchaseReturnId;
      }
      purchaseReturnCount++;
    }
  }

  Future<List<PurchaseReturn>> _getPurchaseReturns() async {
    final QuerySnapshot snapshot = await purchaseReturnsRef.get();
    final List<PurchaseReturn> purchaseReturns = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      purchaseReturns.add(PurchaseReturn.fromJson(data));
    }
    return purchaseReturns;
  }
}

// Dalam PurchaseReturnBloc, tambahkan metode berikut:

Future<String> _getJenisBahanByMaterialId(String materialId) async {
  try {
    final materialQuery = await FirebaseFirestore.instance
        .collection('materials')
        .where('id',
            isEqualTo:
                materialId) // Sesuaikan dengan field yang Anda gunakan dalam 'materials'
        .get();

    if (materialQuery.docs.isNotEmpty) {
      final materialDoc = materialQuery.docs.first;
      final jenisBahan = materialDoc['jenis_bahan'] ?? '';
      return jenisBahan;
    } else {
      return ''; // Atau nilai default sesuai kebutuhan Anda jika tidak ditemukan.
    }
  } catch (e) {
    print('Error saat mengambil jenis bahan: $e');
    return ''; // Atau nilai default sesuai kebutuhan Anda jika terjadi kesalahan.
  }
}

Future<String> _getMaterialIdByPurchaseOrderId(String purchaseOrderId) async {
  try {
    final purchaseOrderQuery = await FirebaseFirestore.instance
        .collection('purchase_orders')
        .where('id',
            isEqualTo: purchaseOrderId) // Menggunakan where dan isEqualTo
        .get();

    if (purchaseOrderQuery.docs.isNotEmpty) {
      final purchaseOrderDoc = purchaseOrderQuery.docs.first;
      final materialId = purchaseOrderDoc['material_id'] ?? '';
      return materialId;
    } else {
      return ''; // Atau nilai default sesuai kebutuhan Anda jika tidak ditemukan.
    }
  } catch (e) {
    print('Error saat mengambil material_id: $e');
    return ''; // Atau nilai default sesuai kebutuhan Anda jika terjadi kesalahan.
  }
}
