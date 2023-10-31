import 'package:cloud_functions/cloud_functions.dart';
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
  final String oldPurchaseRequestId;
  UpdatePurchaseOrderEvent(this.purchaseOrderId, this.updatedPurchaseOrder,
      this.oldPurchaseRequestId);
}

class DeletePurchaseOrderEvent extends PurchaseOrderEvent {
  final String purchaseOrderId;
  DeletePurchaseOrderEvent(this.purchaseOrderId);
}

// States
abstract class PurchaseOrderBlocState {}

class LoadingState extends PurchaseOrderBlocState {}

class SuccessState extends PurchaseOrderBlocState {}

class LoadedState extends PurchaseOrderBlocState {
  final List<PurchaseOrder> purchaseOrders;
  LoadedState(this.purchaseOrders);
}

class ErrorState extends PurchaseOrderBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class PurchaseOrderBloc
    extends Bloc<PurchaseOrderEvent, PurchaseOrderBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference purchaseOrdersRef;
  final HttpsCallable purchaseOrderCallable;

  PurchaseOrderBloc()
      : purchaseOrderCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('purchaseOrderValidation'),
        super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    purchaseOrdersRef = _firestore.collection('purchase_orders');
  }

  @override
  Stream<PurchaseOrderBlocState> mapEventToState(
      PurchaseOrderEvent event) async* {
    if (event is AddPurchaseOrderEvent) {
      yield LoadingState();

      final hargaSatuan = event.purchaseOrder.hargaSatuan;
      final jumlah = event.purchaseOrder.jumlah;
      final materialId = event.purchaseOrder.materialId;
      final supplierId = event.purchaseOrder.supplierId;
      final total = event.purchaseOrder.total;
      final purchaseRequestId = event.purchaseOrder.purchaseRequestId;

      if (materialId.isNotEmpty) {
        if (supplierId.isNotEmpty) {
          if (purchaseRequestId.isNotEmpty) {
            try {
              final HttpsCallableResult<dynamic> result =
                  await purchaseOrderCallable.call(<String, dynamic>{
                'hargaSatuan': hargaSatuan,
                'jumlah': jumlah,
                'total': total,
                'materialId': materialId,
                'purchaseRequestId': purchaseRequestId,
                'mode': 'add',
                'oldPurchaseRequestId': ''
              });

              if (result.data['success'] == true) {
                final String nextPurchaseOrderId =
                    await _generateNextPurchaseOrderId();

                await FirebaseFirestore.instance
                    .collection('purchase_orders')
                    .add({
                  'id': nextPurchaseOrderId,
                  'harga_satuan': hargaSatuan,
                  'jumlah': jumlah,
                  'keterangan': event.purchaseOrder.keterangan,
                  'purchase_request_id': purchaseRequestId,
                  'material_id': materialId,
                  'satuan': event.purchaseOrder.satuan,
                  'status': event.purchaseOrder.status,
                  'status_pembayaran': event.purchaseOrder.statusPembayaran,
                  'status_pengiriman': event.purchaseOrder.statusPengiriman,
                  'supplier_id': supplierId,
                  'tanggal_kirim': event.purchaseOrder.tanggalKirim,
                  'tanggal_pesan': event.purchaseOrder.tanggalPesan,
                  'total': total,
                });

                yield SuccessState();
              } else {
                yield ErrorState(result.data['message']);
              }
            } catch (e) {
              yield ErrorState(e.toString());
            }
          } else {
            yield ErrorState("nomor permintaan pembelian tidak boleh kosong");
          }
        } else {
          yield ErrorState("kode supplier tidak boleh kosong");
        }
      } else {
        yield ErrorState("kode bahan tidak boleh kosong");
      }
    } else if (event is UpdatePurchaseOrderEvent) {
      yield LoadingState();

      final purchaseOrderSnapshot = await purchaseOrdersRef
          .where('id', isEqualTo: event.purchaseOrderId)
          .get();

      if (purchaseOrderSnapshot.docs.isNotEmpty) {
        final hargaSatuan = event.updatedPurchaseOrder.hargaSatuan;
        final jumlah = event.updatedPurchaseOrder.jumlah;
        final materialId = event.updatedPurchaseOrder.materialId;
        final supplierId = event.updatedPurchaseOrder.supplierId;
        final total = event.updatedPurchaseOrder.total;
        final purchaseRequestId = event.updatedPurchaseOrder.purchaseRequestId;

        if (materialId.isNotEmpty) {
          if (supplierId.isNotEmpty) {
            if (purchaseRequestId.isNotEmpty) {
              try {
                final HttpsCallableResult<dynamic> result =
                    await purchaseOrderCallable.call(<String, dynamic>{
                  'hargaSatuan': hargaSatuan,
                  'jumlah': jumlah,
                  'total': total,
                  'materialId': materialId,
                  'purchaseRequestId': purchaseRequestId,
                  'mode': 'edit',
                  'oldPurchaseRequestId': event.oldPurchaseRequestId
                });

                if (result.data['success'] == true) {
                  final purchaseOrderDoc = purchaseOrderSnapshot.docs.first;
                  await purchaseOrderDoc.reference.update({
                    'id': event.purchaseOrderId,
                    'harga_satuan': hargaSatuan,
                    'jumlah': jumlah,
                    'keterangan': event.updatedPurchaseOrder.keterangan,
                    'purchase_request_id': purchaseRequestId,
                    'material_id': materialId,
                    'satuan': event.updatedPurchaseOrder.satuan,
                    'status': event.updatedPurchaseOrder.status,
                    'status_pembayaran':
                        event.updatedPurchaseOrder.statusPembayaran,
                    'status_pengiriman':
                        event.updatedPurchaseOrder.statusPengiriman,
                    'supplier_id': supplierId,
                    'tanggal_kirim': event.updatedPurchaseOrder.tanggalKirim,
                    'tanggal_pesan': event.updatedPurchaseOrder.tanggalPesan,
                    'total': total,
                  });
                  yield SuccessState();
                } else {
                  yield ErrorState(result.data['message']);
                }
              } catch (e) {
                yield ErrorState(e.toString());
              }
            } else {
              yield ErrorState("nomor permintaan pembelian tidak boleh kosong");
            }
          } else {
            yield ErrorState('kode supplier tidak boleh kosong');
          }
        } else {
          yield ErrorState('kode bahan tidak boleh kosong');
        }
      } else {
        yield ErrorState(
            'Purchase Order dengan ID ${event.purchaseOrderId} tidak ditemukan.');
      }
    } else if (event is DeletePurchaseOrderEvent) {
      yield LoadingState();
      try {
        final purchaseOrderId = event.purchaseOrderId;

        // Mengambil referensi ke dokumen purchase order yang sesuai
        final purchaseOrderRef =
            purchaseOrdersRef.where('id', isEqualTo: purchaseOrderId);

        // Mengambil data purchase order
        final purchaseOrderDoc = (await purchaseOrderRef.get()).docs.first;
        final purchaseOrderData =
            purchaseOrderDoc.data() as Map<String, dynamic>;
        final purchaseRequestId =
            purchaseOrderData['purchase_request_id'] as String;

        // Mengambil referensi ke dokumen purchase request yang sesuai
        final purchaseRequestRef = _firestore
            .collection('purchase_requests')
            .where('id', isEqualTo: purchaseRequestId);

        final purchaseRequestDoc = (await purchaseRequestRef.get()).docs.first;

        // Mengupdate status purchase request menjadi "Dalam Proses"
        await purchaseRequestDoc.reference
            .update({'status_prq': 'Dalam Proses'});

        // Mengupdate status purchase order menjadi 0
        await purchaseOrderDoc.reference.update({'status': 0});

        yield SuccessState();
      } catch (e) {
        yield ErrorState("Gagal menghapus Purchase Order: $e");
      }
    }
  }

  Future<String> _generateNextPurchaseOrderId() async {
    final QuerySnapshot snapshot = await purchaseOrdersRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int purchaseOrderCount = 1;

    while (true) {
      final nextPurchaseOrderId =
          'PO${purchaseOrderCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextPurchaseOrderId)) {
        return nextPurchaseOrderId;
      }
      purchaseOrderCount++;
    }
  }

  // Future<List<PurchaseOrder>> _getPurchaseOrders() async {
  //   final QuerySnapshot snapshot = await purchaseOrdersRef.get();
  //   final List<PurchaseOrder> purchaseOrders = [];
  //   for (final doc in snapshot.docs) {
  //     final data = doc.data() as Map<String, dynamic>;
  //     purchaseOrders.add(PurchaseOrder.fromJson(data));
  //   }
  //   return purchaseOrders;
  // }
}
