import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getSupplierInfo(String supplierId) async {
    try {
      final productQuery = await firestore
          .collection('suppliers')
          .where('id', isEqualTo: supplierId)
          .get();

      if (productQuery.docs.isNotEmpty) {
        final productDoc = productQuery.docs.first;
        return {
          'id': supplierId,
          'nama': productDoc['nama'] as String,
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting material info: $e');
      return null;
    }
  }
}
