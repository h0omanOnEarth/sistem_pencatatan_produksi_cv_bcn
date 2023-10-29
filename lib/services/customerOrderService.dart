import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getCustomerOrderInfo(
      String customerOrderId) async {
    try {
      final productQuery = await _firestore
          .collection('customer_orders')
          .where('id', isEqualTo: customerOrderId)
          .get();

      if (productQuery.docs.isNotEmpty) {
        final productDoc = productQuery.docs.first;
        return {
          'id': customerOrderId,
          'customer_id': productDoc['customer_id'] as String,
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
