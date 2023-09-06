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
  UpdatePurchaseReturnEvent(this.purchaseReturnId, this.updatedPurchaseReturn);
}

class DeletePurchaseReturnEvent extends PurchaseReturnEvent {
  final String purchaseReturnId;
  DeletePurchaseReturnEvent(this.purchaseReturnId);
}

// States
abstract class PurchaseReturnBlocState {}

class LoadingState extends PurchaseReturnBlocState {}

class LoadedState extends PurchaseReturnBlocState {
  final List<PurchaseReturn> purchaseReturns;
  LoadedState(this.purchaseReturns);
}

class ErrorState extends PurchaseReturnBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class PurchaseReturnBloc extends Bloc<PurchaseReturnEvent, PurchaseReturnBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference purchaseReturnsRef;

  PurchaseReturnBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    purchaseReturnsRef = _firestore.collection('purchase_returns');
  }

  @override
  Stream<PurchaseReturnBlocState> mapEventToState(PurchaseReturnEvent event) async* {
    if (event is AddPurchaseReturnEvent) {
      yield LoadingState();
      try {
        final String nextPurchaseReturnId = await _generateNextPurchaseReturnId();
         // Ambil 'material_id' dari Firestore berdasarkan 'purchaseOrderId'
        final materialId = await _getMaterialIdByPurchaseOrderId(event.purchaseReturn.purchaseOrderId);

        // Ambil 'jenis_bahan' dari Firestore berdasarkan 'material_id'
        final jenisBahan = await _getJenisBahanByMaterialId(materialId);

        await FirebaseFirestore.instance.collection('purchase_returns').add({
          'id': nextPurchaseReturnId,
          'purchase_order_id': event.purchaseReturn.purchaseOrderId,
          'jumlah': event.purchaseReturn.jumlah,
          'satuan': event.purchaseReturn.satuan,
          'alamat_pengembalian': event.purchaseReturn.alamatPengembalian,
          'alasan': event.purchaseReturn.alasan,
          'status': event.purchaseReturn.status,
          'tanggal_pengembalian': event.purchaseReturn.tanggalPengembalian,
          'jenis_bahan' : jenisBahan,
          'keterangan': event.purchaseReturn.keterangan
        });

        yield LoadedState(await _getPurchaseReturns());
      } catch (e) {
        yield ErrorState("Gagal menambahkan Purchase Return.");
      }
    } else if (event is UpdatePurchaseReturnEvent) {
      yield LoadingState();
      try {
        final purchaseReturnSnapshot = await purchaseReturnsRef.where('id', isEqualTo: event.purchaseReturnId).get();
        if (purchaseReturnSnapshot.docs.isNotEmpty) {
           final purchaseReturnDoc = purchaseReturnSnapshot.docs.first;
          // Ambil 'material_id' dari Firestore berdasarkan 'purchaseOrderId'
          final materialId = await _getMaterialIdByPurchaseOrderId(event.updatedPurchaseReturn.purchaseOrderId);
          // Ambil 'jenis_bahan' dari Firestore berdasarkan 'material_id'
          final jenisBahan = await _getJenisBahanByMaterialId(materialId);
          await purchaseReturnDoc.reference.update({
            ...event.updatedPurchaseReturn.toJson(),
            'jenis_bahan': jenisBahan, // Set nilai jenis_bahan
          });
          final purchaseReturns = await _getPurchaseReturns();

          yield LoadedState(purchaseReturns);
        } else {
          yield ErrorState('Purchase Return dengan ID ${event.purchaseReturnId} tidak ditemukan.');
        }
      } catch (e) {
        yield ErrorState("Gagal mengubah Purchase Return.");
      }
    } else if (event is DeletePurchaseReturnEvent) {
      yield LoadingState();
      try {
        final purchaseReturnSnapshot = await purchaseReturnsRef.where('id', isEqualTo: event.purchaseReturnId).get();
        for (QueryDocumentSnapshot documentSnapshot in purchaseReturnSnapshot.docs) {
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
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int purchaseReturnCount = 1;

    while (true) {
      final nextPurchaseReturnId = 'PR${purchaseReturnCount.toString().padLeft(3, '0')}';
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
        .where('id', isEqualTo: materialId) // Sesuaikan dengan field yang Anda gunakan dalam 'materials'
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
        .doc(purchaseOrderId)
        .get();

    if (purchaseOrderQuery.exists) {
      final materialId = purchaseOrderQuery['material_id'] ?? '';
      return materialId;
    } else {
      return ''; // Atau nilai default sesuai kebutuhan Anda jika tidak ditemukan.
    }
  } catch (e) {
    print('Error saat mengambil material_id: $e');
    return ''; // Atau nilai default sesuai kebutuhan Anda jika terjadi kesalahan.
  }
}
