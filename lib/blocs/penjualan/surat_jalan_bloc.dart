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

  ShipmentBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<ShipmentBlocState> mapEventToState(ShipmentEvent event) async* {
    if (event is AddShipmentEvent) {
      yield LoadingState();
      try {
        // Generate a new shipment ID (or use an existing one if you have it)
        final nextShipmentId = await _generateNextShipmentId();

        // Create a reference to the shipment document using the appropriate ID
        final shipmentRef = _firestore.collection('shipments').doc(nextShipmentId);

        // Set shipment data
        final Map<String, dynamic> shipmentData = {
          'id': nextShipmentId,
          'status': event.shipment.status,
          'alamat_penerima': event.shipment.alamatPenerima,
          'catatan': event.shipment.catatan,
          'delivery_order_id': event.shipment.deliveryOrderId,
          'status_shp': event.shipment.statusShp,
          'total_pcs': event.shipment.totalPcs,
          'tanggal_pembuatan': event.shipment.tanggalPembuatan,
        };

        // Add shipment data to Firestore
        await shipmentRef.set(shipmentData);

        // Create a reference to the subcollection 'detail_shipments' within the shipment document
        final detailShipmentRef = shipmentRef.collection('detail_shipments');

        if (event.shipment.detailListShipment.isNotEmpty) {
          int detailCount = 1;
          for (var detailShipment in event.shipment.detailListShipment) {
            final nextDetailShipmentId = '$nextShipmentId${'D${detailCount.toString().padLeft(3, '0')}'}';

            // Add detail shipment document to the 'detail_shipments' collection
            await detailShipmentRef.doc(nextDetailShipmentId).set({
              'id': nextDetailShipmentId,
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
        
        yield LoadedState(event.shipment);
      } catch (e) {
        yield ErrorState("Failed to add Shipment.");
      }
    } else if (event is UpdateShipmentEvent) {
      yield LoadingState();
      try {
        // Get a reference to the shipment document to be updated
        final shipmentToUpdateRef = _firestore.collection('shipments').doc(event.shipmentId);

        // Set new shipment data
        final Map<String, dynamic> shipmentData = {
          'id': event.shipmentId,
          'status': event.shipment.status,
          'alamat_penerima': event.shipment.alamatPenerima,
          'catatan': event.shipment.catatan,
          'delivery_order_id': event.shipment.deliveryOrderId,
          'status_shp': event.shipment.statusShp,
          'total_pcs': event.shipment.totalPcs,
          'tanggal_pembuatan': event.shipment.tanggalPembuatan,
        };

        // Update the shipment data in the existing document
        await shipmentToUpdateRef.set(shipmentData);

        // Delete all documents in the 'detail_shipments' subcollection first
        final detailShipmentCollectionRef = shipmentToUpdateRef.collection('detail_shipments');
        final detailShipmentDocs = await detailShipmentCollectionRef.get();
        for (var doc in detailShipmentDocs.docs) {
          await doc.reference.delete();
        }

        // Add new detail shipment documents to the 'detail_shipments' subcollection
        if (event.shipment.detailListShipment.isNotEmpty) {
          int detailCount = 1;
          for (var detailShipment in event.shipment.detailListShipment) {
            final nextDetailShipmentId = 'D${detailCount.toString().padLeft(3, '0')}';
            final detailId = event.shipmentId + nextDetailShipmentId;

            // Add detail shipment document to the 'detail_shipments' collection
            await detailShipmentCollectionRef.doc(detailId).set({
              'id': detailId,
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

        yield ShipmentUpdatedState();
      } catch (e) {
        yield ErrorState("Failed to update Shipment.");
      }
    } else if (event is DeleteShipmentEvent) {
      yield LoadingState();
      try {
        // Get a reference to the shipment document to be deleted
        final shipmentToDeleteRef = _firestore.collection('shipments').doc(event.shipmentId);

        // Get a reference to the 'detail_shipments' subcollection within the shipment document
        final detailShipmentCollectionRef = shipmentToDeleteRef.collection('detail_shipments');

        // Delete all documents in the 'detail_shipments' subcollection
        final detailShipmentDocs = await detailShipmentCollectionRef.get();
        for (var doc in detailShipmentDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents in the subcollection, delete the shipment document itself
        await shipmentToDeleteRef.delete();

        yield ShipmentDeletedState();
      } catch (e) {
        yield ErrorState("Failed to delete Shipment.");
      }
    }
  }

  Future<String> _generateNextShipmentId() async {
    final shipmentsRef = _firestore.collection('shipments');
    final QuerySnapshot snapshot = await shipmentsRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int shipmentCount = 1;

    while (true) {
      final nextShipmentId = 'SHP${shipmentCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextShipmentId)) {
        return nextShipmentId;
      }
      shipmentCount++;
    }
  }
}
