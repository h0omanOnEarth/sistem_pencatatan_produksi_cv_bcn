import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getCustomerInfo(String customerId) async {
    try {
      final productQuery = await _firestore
          .collection('customers')
          .where('id', isEqualTo: customerId)
          .get();

      if (productQuery.docs.isNotEmpty) {
        final productDoc = productQuery.docs.first;
        return {
          'id': customerId,
          'nama': productDoc['nama'] as String,
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
