import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/delivery_order.dart';

// Events
abstract class DeliveryOrderEvent {}

class AddDeliveryOrderEvent extends DeliveryOrderEvent {
  final DeliveryOrder deliveryOrder;
  AddDeliveryOrderEvent(this.deliveryOrder);
}

class UpdateDeliveryOrderEvent extends DeliveryOrderEvent {
  final String deliveryOrderId;
  final DeliveryOrder deliveryOrder;
  UpdateDeliveryOrderEvent(this.deliveryOrderId, this.deliveryOrder);
}

class DeleteDeliveryOrderEvent extends DeliveryOrderEvent {
  final String deliveryOrderId;
  DeleteDeliveryOrderEvent(this.deliveryOrderId);
}

// States
abstract class DeliveryOrderBlocState {}

class LoadingState extends DeliveryOrderBlocState {}

class SuccessState extends DeliveryOrderBlocState {}

class LoadedState extends DeliveryOrderBlocState {
  final DeliveryOrder deliveryOrder;
  LoadedState(this.deliveryOrder);
}

class DeliveryOrderUpdatedState extends DeliveryOrderBlocState {}

class DeliveryOrderDeletedState extends DeliveryOrderBlocState {}

class ErrorState extends DeliveryOrderBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class DeliveryOrderBloc
    extends Bloc<DeliveryOrderEvent, DeliveryOrderBlocState> {
  late FirebaseFirestore _firestore;
  final HttpsCallable deliveryOrderCallable; //karena sama

  DeliveryOrderBloc()
      : deliveryOrderCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('deliveryOrderValidate'),
        super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<DeliveryOrderBlocState> mapEventToState(
      DeliveryOrderEvent event) async* {
    if (event is AddDeliveryOrderEvent) {
      yield LoadingState();

      final customerOrderId = event.deliveryOrder.customerOrderId;
      final estimasiWaktu = event.deliveryOrder.estimasiWaktu;
      final metodePengiriman = event.deliveryOrder.metodePengiriman;
      final alamatPengiriman = event.deliveryOrder.alamatPengiriman;
      final satuan = event.deliveryOrder.satuan;
      final tanggalPesananPengiriman =
          event.deliveryOrder.tanggalPesananPengiriman;
      final tanggalRequestPengiriman =
          event.deliveryOrder.tanggalRequestPengiriman;
      final totalBarang = event.deliveryOrder.totalBarang;
      final totalHarga = event.deliveryOrder.totalHarga;
      final catatan = event.deliveryOrder.catatan;
      final products = event.deliveryOrder.detailDeliveryOrderList;

      if (customerOrderId.isNotEmpty) {
        if (alamatPengiriman.isNotEmpty) {
          try {
            final HttpsCallableResult<dynamic> result =
                await deliveryOrderCallable.call(<String, dynamic>{
              'products': products?.map((product) => product.toJson()).toList(),
              'totalProduk': totalBarang,
              'totalHarga': totalHarga
            });

            if (result.data['success'] == true) {
              final nextDeliveryOrderId = await _generateNextDeliveryOrderId();
              final deliveryOrderRef = _firestore
                  .collection('delivery_orders')
                  .doc(nextDeliveryOrderId);

              final Map<String, dynamic> deliveryOrderData = {
                'id': nextDeliveryOrderId,
                'customer_order_id': customerOrderId,
                'estimasi_waktu': estimasiWaktu,
                'metode_pengiriman': metodePengiriman,
                'alamat_pengiriman': alamatPengiriman,
                'satuan': satuan,
                'status': event.deliveryOrder.status,
                'status_pesanan_pengiriman':
                    event.deliveryOrder.statusPesananPengiriman,
                'tanggal_pesanan_pengiriman': tanggalPesananPengiriman,
                'tanggal_request_pengiriman': tanggalRequestPengiriman,
                'total_barang': totalBarang,
                'total_harga': totalHarga,
                'catatan': catatan
              };

              await deliveryOrderRef.set(deliveryOrderData);

              // Buat referensi ke subcollection 'detail_customer_orders' dalam dokumen customer order
              final detailDeliveryOrderRef =
                  deliveryOrderRef.collection('detail_delivery_orders');

              if (event.deliveryOrder.detailDeliveryOrderList != null &&
                  event.deliveryOrder.detailDeliveryOrderList!.isNotEmpty) {
                int detailCount = 1;
                for (var detailDeliveryOrder
                    in event.deliveryOrder.detailDeliveryOrderList!) {
                  final nextDetailDeliveryId =
                      '$nextDeliveryOrderId${'D${detailCount.toString().padLeft(3, '0')}'}';

                  // Tambahkan dokumen detail customer order dalam koleksi 'detail_customer_orders'
                  await detailDeliveryOrderRef.add({
                    'id': nextDetailDeliveryId,
                    'customer_id': nextDeliveryOrderId,
                    'product_id': detailDeliveryOrder.product_id,
                    'jumlah': detailDeliveryOrder.jumlah,
                    'harga_satuan': detailDeliveryOrder.hargaSatuan,
                    'satuan': detailDeliveryOrder.satuan,
                    'status': detailDeliveryOrder.status,
                    'subtotal': detailDeliveryOrder.subtotal
                  });
                  detailCount++;
                }
              }
              yield SuccessState();
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState("alamat pengiriman tidak boleh kosong");
        }
      } else {
        yield ErrorState("nomor pesanan pelanggan tidak boleh kosong");
      }
    } else if (event is UpdateDeliveryOrderEvent) {
      yield LoadingState();

      final customerOrderId = event.deliveryOrder.customerOrderId;
      final estimasiWaktu = event.deliveryOrder.estimasiWaktu;
      final metodePengiriman = event.deliveryOrder.metodePengiriman;
      final alamatPengiriman = event.deliveryOrder.alamatPengiriman;
      final satuan = event.deliveryOrder.satuan;
      final tanggalPesananPengiriman =
          event.deliveryOrder.tanggalPesananPengiriman;
      final tanggalRequestPengiriman =
          event.deliveryOrder.tanggalRequestPengiriman;
      final totalBarang = event.deliveryOrder.totalBarang;
      final totalHarga = event.deliveryOrder.totalHarga;
      final catatan = event.deliveryOrder.catatan;
      final products = event.deliveryOrder.detailDeliveryOrderList;

      if (customerOrderId.isNotEmpty) {
        if (alamatPengiriman.isNotEmpty) {
          try {
            final HttpsCallableResult<dynamic> result =
                await deliveryOrderCallable.call(<String, dynamic>{
              'products': products?.map((product) => product.toJson()).toList(),
              'totalProduk': totalBarang,
              'totalHarga': totalHarga
            });

            if (result.data['success'] == true) {
              final deliveryOrderToUpdateRef = _firestore
                  .collection('delivery_orders')
                  .doc(event.deliveryOrderId);

              final Map<String, dynamic> deliveryOrderData = {
                'id': event.deliveryOrderId,
                'customer_order_id': customerOrderId,
                'estimasi_waktu': estimasiWaktu,
                'metode_pengiriman': metodePengiriman,
                'alamat_pengiriman': alamatPengiriman,
                'satuan': satuan,
                'status': event.deliveryOrder.status,
                'status_pesanan_pengiriman':
                    event.deliveryOrder.statusPesananPengiriman,
                'tanggal_pesanan_pengiriman': tanggalPesananPengiriman,
                'tanggal_request_pengiriman': tanggalRequestPengiriman,
                'total_barang': totalBarang,
                'total_harga': totalHarga,
                'catatan': catatan
              };

              await deliveryOrderToUpdateRef.set(deliveryOrderData);

              final detailDeliveryOrderCollectionRef =
                  deliveryOrderToUpdateRef.collection('detail_delivery_orders');
              final detailDeliveryOrderDocs =
                  await detailDeliveryOrderCollectionRef.get();
              for (var doc in detailDeliveryOrderDocs.docs) {
                await doc.reference.delete();
              }

              if (event.deliveryOrder.detailDeliveryOrderList != null &&
                  event.deliveryOrder.detailDeliveryOrderList!.isNotEmpty) {
                int detailCount = 1;
                for (var detailDeliveryOrder
                    in event.deliveryOrder.detailDeliveryOrderList!) {
                  final nextDetailDeliveryOrderId =
                      'D${detailCount.toString().padLeft(3, '0')}';
                  final detailId =
                      event.deliveryOrderId + nextDetailDeliveryOrderId;

                  await detailDeliveryOrderCollectionRef.add({
                    'id': detailId,
                    'delivery_order_id': event.deliveryOrderId,
                    'product_id': detailDeliveryOrder.product_id,
                    'jumlah': detailDeliveryOrder.jumlah,
                    'harga_satuan': detailDeliveryOrder.hargaSatuan,
                    'satuan': detailDeliveryOrder.satuan,
                    'status': detailDeliveryOrder.status,
                    'subtotal': detailDeliveryOrder.subtotal,
                  });
                  detailCount++;
                }
              }
              yield SuccessState();
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState("alamat pengiriman tidak boleh kosong");
        }
      } else {
        yield ErrorState("nomor pesanan pelanggan tidak boleh kosong");
      }
    } else if (event is DeleteDeliveryOrderEvent) {
      yield LoadingState();
      try {
        final deliveryOrderId = event.deliveryOrderId;

        // Mengupdate status menjadi 0 pada dokumen Delivery Order
        final deliveryOrderRef =
            _firestore.collection('delivery_orders').doc(deliveryOrderId);
        await deliveryOrderRef.update({'status': 0});

        // Mengambil koleksi "detail_delivery_orders"
        final detailDeliveryOrderCollectionRef =
            deliveryOrderRef.collection('detail_delivery_orders');

        // Mengambil semua dokumen dalam subkoleksi
        final detailDeliveryOrderDocs =
            await detailDeliveryOrderCollectionRef.get();

        // Mengupdate status menjadi 0 pada setiap dokumen dalam subkoleksi
        for (final doc in detailDeliveryOrderDocs.docs) {
          await doc.reference.update({'status': 0});
        }

        // Update the status of the corresponding customer_order
        final deliveryOrderData = await deliveryOrderRef.get();
        final customerOrderId = deliveryOrderData['customer_order_id'];
        if (customerOrderId != null) {
          await updateCustomerOrderStatus(customerOrderId);
        }

        yield SuccessState();
      } catch (e) {
        yield ErrorState("Gagal menghapus Delivery Order: $e");
      }
    }
  }

  Future<String> _generateNextDeliveryOrderId() async {
    final deliveryOrdersRef = _firestore.collection('delivery_orders');
    final QuerySnapshot snapshot = await deliveryOrdersRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int deliveryCount = 1;

    while (true) {
      final nextDeliveryOrderId =
          'DO${deliveryCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextDeliveryOrderId)) {
        return nextDeliveryOrderId;
      }
      deliveryCount++;
    }
  }

  // Helper function to update the status of customer_order
  Future<void> updateCustomerOrderStatus(String customerOrderId) async {
    final customerOrderRef = _firestore.collection('customer_orders');
    await customerOrderRef
        .doc(customerOrderId)
        .update({'status_pesanan': 'Dalam Proses'});
  }
}
