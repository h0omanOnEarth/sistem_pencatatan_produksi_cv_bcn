import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/purchase_order.dart';
// Events
abstract class PurchaseOrderEvent {}

class AddPurchaseOrderEvent extends PurchaseOrderEvent {
  final PurchaseOrder purchaseOrder;
  AddPurchaseOrderEvent(this.purchaseOrder);
}

class UpdatePurchaseOrderEvent extends PurchaseOrderEvent {
  final String purchaseOrderId;
  final PurchaseOrder updatedPurchaseOrder;
  UpdatePurchaseOrderEvent(this.purchaseOrderId, this.updatedPurchaseOrder);
}

class DeletePurchaseOrderEvent extends PurchaseOrderEvent {
  final String purchaseOrderId;
  DeletePurchaseOrderEvent(this.purchaseOrderId);
}

// States
abstract class PurchaseOrderBlocState {}

class LoadingState extends PurchaseOrderBlocState {}

class LoadedState extends PurchaseOrderBlocState {
  final List<PurchaseOrder> purchaseOrders;
  LoadedState(this.purchaseOrders);
}

class ErrorState extends PurchaseOrderBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class PurchaseOrderBloc extends Bloc<PurchaseOrderEvent, PurchaseOrderBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference purchaseOrdersRef;

  PurchaseOrderBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    purchaseOrdersRef = _firestore.collection('purchase_orders');
  }

  @override
  Stream<PurchaseOrderBlocState> mapEventToState(PurchaseOrderEvent event) async* {
    if (event is AddPurchaseOrderEvent) {
      yield LoadingState();
      try {
        final String nextPurchaseOrderId = await _generateNextPurchaseOrderId();

        await FirebaseFirestore.instance.collection('purchase_orders').add({
          'id': nextPurchaseOrderId,
          'harga_satuan': event.purchaseOrder.hargaSatuan,
          'jumlah': event.purchaseOrder.jumlah,
          'keterangan': event.purchaseOrder.keterangan,
          'material_id': event.purchaseOrder.materialId,
          'satuan': event.purchaseOrder.satuan,
          'status': event.purchaseOrder.status,
          'status_pembayaran': event.purchaseOrder.statusPembayaran,
          'status_pengiriman': event.purchaseOrder.statusPengiriman,
          'supplier_id': event.purchaseOrder.supplierId,
          'tanggal_kirim': event.purchaseOrder.tanggalKirim,
          'tanggal_pesan': event.purchaseOrder.tanggalPesan,
          'total': event.purchaseOrder.total,
        });

        yield LoadedState(await _getPurchaseOrders());
      } catch (e) {
        yield ErrorState("Gagal menambahkan Purchase Order.");
      }
    } else if (event is UpdatePurchaseOrderEvent) {
      yield LoadingState();
      try {
        final purchaseOrderSnapshot = await purchaseOrdersRef.where('id', isEqualTo: event.purchaseOrderId).get();
        if (purchaseOrderSnapshot.docs.isNotEmpty) {
          final purchaseOrderDoc = purchaseOrderSnapshot.docs.first;
          await purchaseOrderDoc.reference.update(event.updatedPurchaseOrder.toJson());
          final purchaseOrders = await _getPurchaseOrders();
          yield LoadedState(purchaseOrders);
        } else {
          yield ErrorState('Purchase Order dengan ID ${event.purchaseOrderId} tidak ditemukan.');
        }
      } catch (e) {
        yield ErrorState("Gagal mengubah Purchase Order.");
      }
    } else if (event is DeletePurchaseOrderEvent) {
      yield LoadingState();
      try {
        final purchaseOrderSnapshot = await purchaseOrdersRef.where('id', isEqualTo: event.purchaseOrderId).get();
        for (QueryDocumentSnapshot documentSnapshot in purchaseOrderSnapshot.docs) {
          await documentSnapshot.reference.delete();
        }
        yield LoadedState(await _getPurchaseOrders());
      } catch (e) {
        yield ErrorState("Gagal menghapus Purchase Order.");
      }
    }
  }

  Future<String> _generateNextPurchaseOrderId() async {
    final QuerySnapshot snapshot = await purchaseOrdersRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int purchaseOrderCount = 1;

    while (true) {
      final nextPurchaseOrderId = 'PO${purchaseOrderCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextPurchaseOrderId)) {
        return nextPurchaseOrderId;
      }
      purchaseOrderCount++;
    }
  }

  Future<List<PurchaseOrder>> _getPurchaseOrders() async {
    final QuerySnapshot snapshot = await purchaseOrdersRef.get();
    final List<PurchaseOrder> purchaseOrders = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      purchaseOrders.add(PurchaseOrder.fromJson(data));
    }
    return purchaseOrders;
  }
}
