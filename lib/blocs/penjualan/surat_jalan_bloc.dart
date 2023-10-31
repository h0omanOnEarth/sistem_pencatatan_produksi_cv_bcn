import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/surat_jalan.dart';

// Events
abstract class ShipmentEvent {}

class AddShipmentEvent extends ShipmentEvent {
  final Shipment shipment;
  AddShipmentEvent(this.shipment);
}

class UpdateShipmentEvent extends ShipmentEvent {
  final String shipmentId;
  final Shipment shipment;
  UpdateShipmentEvent(this.shipmentId, this.shipment);
}

class DeleteShipmentEvent extends ShipmentEvent {
  final String shipmentId;
  DeleteShipmentEvent(this.shipmentId);
}

// States
abstract class ShipmentBlocState {}

class LoadingState extends ShipmentBlocState {}

class SuccessState extends ShipmentBlocState {}

class LoadedState extends ShipmentBlocState {
  final Shipment shipment;
  LoadedState(this.shipment);
}

class ShipmentUpdatedState extends ShipmentBlocState {}

class ShipmentDeletedState extends ShipmentBlocState {}

class ErrorState extends ShipmentBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class ShipmentBloc extends Bloc<ShipmentEvent, ShipmentBlocState> {
  late FirebaseFirestore _firestore;
  final HttpsCallable suratJalanCallable;

  ShipmentBloc()
      : suratJalanCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('suratJalanValidation'),
        super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<ShipmentBlocState> mapEventToState(ShipmentEvent event) async* {
    if (event is AddShipmentEvent) {
      yield LoadingState();

      final deliveryOrderId = event.shipment.deliveryOrderId;
      final totalPcs = event.shipment.totalPcs;
      final products = event.shipment.detailListShipment;

      if (deliveryOrderId.isNotEmpty) {
        try {
          final HttpsCallableResult<dynamic> result =
              await suratJalanCallable.call(<String, dynamic>{
            'products': products.map((product) => product.toJson()).toList(),
            'totalPcs': totalPcs,
            'deliveryOrderId': deliveryOrderId,
            'mode': 'add'
          });

          if (result.data['success'] == true) {
            final nextShipmentId = await _generateNextShipmentId();
            final shipmentRef =
                _firestore.collection('shipments').doc(nextShipmentId);
            final Map<String, dynamic> shipmentData = {
              'id': nextShipmentId,
              'status': event.shipment.status,
              'alamat_penerima': event.shipment.alamatPenerima,
              'catatan': event.shipment.catatan,
              'delivery_order_id': deliveryOrderId,
              'status_shp': event.shipment.statusShp,
              'total_pcs': totalPcs,
              'tanggal_pembuatan': event.shipment.tanggalPembuatan,
            };
            await shipmentRef.set(shipmentData);
            final detailShipmentRef =
                shipmentRef.collection('detail_shipments');
            if (event.shipment.detailListShipment.isNotEmpty) {
              int detailCount = 1;
              for (var detailShipment in event.shipment.detailListShipment) {
                final nextDetailShipmentId =
                    '$nextShipmentId${'D${detailCount.toString().padLeft(3, '0')}'}';
                await detailShipmentRef.doc(nextDetailShipmentId).set({
                  'id': nextDetailShipmentId,
                  'shipment_id': nextShipmentId,
                  'jumlah_dus_pesanan': detailShipment.jumlahDusPesanan,
                  'jumlah_pengiriman': detailShipment.jumlahPengiriman,
                  'jumlah_pengiriman_dus': detailShipment.jumlahPengirimanDus,
                  'jumlah_pesanan': detailShipment.jumlahPesanan,
                  'product_id': detailShipment.productId,
                  'status': detailShipment.status,
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
        yield ErrorState("nomor perintah pengiriman tidak boleh kosong");
      }
    } else if (event is UpdateShipmentEvent) {
      yield LoadingState();

      final deliveryOrderId = event.shipment.deliveryOrderId;
      final totalPcs = event.shipment.totalPcs;
      final products = event.shipment.detailListShipment;

      if (deliveryOrderId.isNotEmpty) {
        try {
          final HttpsCallableResult<dynamic> result =
              await suratJalanCallable.call(<String, dynamic>{
            'products': products.map((product) => product.toJson()).toList(),
            'totalPcs': totalPcs,
            'deliveryOrderId': deliveryOrderId,
            'mode': 'edit'
          });

          if (result.data['success'] == true) {
            final shipmentToUpdateRef =
                _firestore.collection('shipments').doc(event.shipmentId);
            final Map<String, dynamic> shipmentData = {
              'id': event.shipmentId,
              'status': event.shipment.status,
              'alamat_penerima': event.shipment.alamatPenerima,
              'catatan': event.shipment.catatan,
              'delivery_order_id': deliveryOrderId,
              'status_shp': event.shipment.statusShp,
              'total_pcs': totalPcs,
              'tanggal_pembuatan': event.shipment.tanggalPembuatan,
            };
            await shipmentToUpdateRef.set(shipmentData);
            final detailShipmentCollectionRef =
                shipmentToUpdateRef.collection('detail_shipments');
            final detailShipmentDocs = await detailShipmentCollectionRef.get();
            for (var doc in detailShipmentDocs.docs) {
              await doc.reference.delete();
            }
            if (event.shipment.detailListShipment.isNotEmpty) {
              int detailCount = 1;
              for (var detailShipment in event.shipment.detailListShipment) {
                final nextDetailShipmentId =
                    'D${detailCount.toString().padLeft(3, '0')}';
                final detailId = event.shipmentId + nextDetailShipmentId;
                await detailShipmentCollectionRef.doc(detailId).set({
                  'id': detailId,
                  'shipment_id': detailShipment.shipmentId,
                  'jumlah_dus_pesanan': detailShipment.jumlahDusPesanan,
                  'jumlah_pengiriman': detailShipment.jumlahPengiriman,
                  'jumlah_pengiriman_dus': detailShipment.jumlahPengirimanDus,
                  'jumlah_pesanan': detailShipment.jumlahPesanan,
                  'product_id': detailShipment.productId,
                  'status': detailShipment.status,
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
        yield ErrorState("nomor perintah pengiriman tidak boleh kosong");
      }
    } else if (event is DeleteShipmentEvent) {
      yield LoadingState();
      try {
        final shipmentId = event.shipmentId;
        final firestore = FirebaseFirestore.instance;

        // Mengupdate status menjadi 0 pada dokumen Shipment
        final shipmentRef = firestore.collection('shipments').doc(shipmentId);
        await shipmentRef.update({'status': 0});

        // Mengambil koleksi "detail_shipments"
        final detailShipmentCollectionRef =
            shipmentRef.collection('detail_shipments');

        // Mengambil semua dokumen dalam subkoleksi
        final detailShipmentDocs = await detailShipmentCollectionRef.get();

        for (final doc in detailShipmentDocs.docs) {
          final detailShipmentData = doc.data() as Map<String, dynamic>;
          final productId = detailShipmentData['product_id'] as String;
          final jumlahPengiriman =
              detailShipmentData['jumlah_pengiriman'] as int;

          // Mengambil referensi ke produk yang sesuai
          final productRef = firestore
              .collection('products')
              .where('id', isEqualTo: productId);

          // Mengambil data produk
          final productDoc = (await productRef.get()).docs.first;
          final productData = productDoc.data();
          final currentStock = productData['stok'] as int;

          // Mengupdate stok produk
          await productDoc.reference
              .update({'stok': currentStock + jumlahPengiriman});

          // Mengupdate status menjadi 0 pada dokumen detail_shipments
          await doc.reference.update({'status': 0});
        }

        // Mengubah status pada delivery_orders dengan id = delivery_order_id menjadi 'Dalam Proses'
        final shipmentData = await shipmentRef.get();
        final deliveryOrderId = shipmentData['delivery_order_id'];
        if (deliveryOrderId != null) {
          await updateDeliveryOrderStatus(deliveryOrderId);
        }

        yield SuccessState();
      } catch (e) {
        yield ErrorState("Gagal menghapus Shipment: $e");
      }
    }
  }

  Future<String> _generateNextShipmentId() async {
    final shipmentsRef = _firestore.collection('shipments');
    final QuerySnapshot snapshot = await shipmentsRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int shipmentCount = 1;

    while (true) {
      final nextShipmentId = 'SHP${shipmentCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextShipmentId)) {
        return nextShipmentId;
      }
      shipmentCount++;
    }
  }

  // Helper function to update the status of delivery_order
  Future<void> updateDeliveryOrderStatus(String deliveryOrderId) async {
    final deliveryOrderRef = _firestore.collection('delivery_orders');
    await deliveryOrderRef
        .doc(deliveryOrderId)
        .update({'status_pesanan_pengiriman': 'Dalam Proses'});
  }
}
