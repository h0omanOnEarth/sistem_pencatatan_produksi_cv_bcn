// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDeliveryOrderInfo(
      String deliveryOrderId) async {
    try {
      final productQuery = await _firestore
          .collection('delivery_orders')
          .where('id', isEqualTo: deliveryOrderId)
          .get();

      if (productQuery.docs.isNotEmpty) {
        final productDoc = productQuery.docs.first;
        return {
          'id': deliveryOrderId,
          'customerOrderId': productDoc['customer_order_id'] as String,
          'metodePengiriman': productDoc['metode_pengiriman'] as String,
          'namaEkspedisi': productDoc['nama_ekspedisi'] as String
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting product info: $e');
      return null;
    }
  }
}
