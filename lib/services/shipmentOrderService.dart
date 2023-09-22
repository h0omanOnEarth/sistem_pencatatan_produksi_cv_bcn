import 'package:cloud_firestore/cloud_firestore.dart';

class ShipmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>?> getDetailShipments(String shipmentId) async {
    try {
      final detailShipmentsQuery = await _firestore
          .collection('shipments')
          .doc(shipmentId)
          .collection('detail_shipments')
          .get();

      if (detailShipmentsQuery.docs.isNotEmpty) {
        final List<Map<String, dynamic>> detailShipments = [];

        for (final doc in detailShipmentsQuery.docs) {
          final detailShipmentData = doc.data();

          // Pastikan data yang dibutuhkan tersedia sebelum menambahkannya
          if (detailShipmentData['jumlah_pengiriman'] != null &&
              detailShipmentData['jumlah_pengiriman_dus'] != null) {
            detailShipments.add({
              'id': doc.id,
              'product_id': detailShipmentData['product_id'],
              'jumlahPengiriman': detailShipmentData['jumlah_pengiriman'] as int,
              'jumlahPengirimanDus': detailShipmentData['jumlah_pengiriman_dus'] as int,
            });
          }
        }

        return detailShipments;
      } else {
        return null; // Kembalikan null jika dokumen detail_shipments tidak ditemukan
      }
    } catch (e) {
      print('Error getting shipment info: $e');
      return null; // Kembalikan null jika terjadi kesalahan
    }
  }
}
