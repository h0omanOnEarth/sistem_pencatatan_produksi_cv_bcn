import 'package:cloud_firestore/cloud_firestore.dart';

class FakturService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getFakturInfo(String invoiceId) async {
    try {
      final productQuery = await firestore
          .collection('invoices')
          .where('id', isEqualTo: invoiceId)
          .get();

      if (productQuery.docs.isNotEmpty) {
        final productDoc = productQuery.docs.first;
        return {
          'id': invoiceId,
          'shipmentId': productDoc['shipment_id'] as String,
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
