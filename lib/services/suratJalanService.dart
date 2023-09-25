import 'package:cloud_firestore/cloud_firestore.dart';

class SuratJalanService{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> generateNextShipmentId() async {
    final shipmentsRef = firestore.collection('shipments');
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

    Future<Map<String, dynamic>?> getSuratJalanInfo(String shipmentId) async {
  try {
    final productQuery = await firestore
        .collection('shipments')
        .where('id', isEqualTo: shipmentId)
        .get();

    if (productQuery.docs.isNotEmpty) {
      final productDoc = productQuery.docs.first;
      return {
        'id': shipmentId,
        'deliveryOrderId': productDoc['delivery_order_id'] as String,
        'alamatPenerima': productDoc['alamat_penerima'] as String
      };
    } else {
      return null;
    }
  } catch (e) {
    print('Error getting product info: $e');
    return null;
  }
}


Future<List<Map<String, dynamic>>?> getDetailShipments(String shipmentId) async {
    try {
      final detailShipmentsQuery = await firestore
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