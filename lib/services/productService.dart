import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getProductInfo(String productId) async {
    try {
      final productQuery = await _firestore
          .collection('products')
          .where('id', isEqualTo: productId)
          .get();

      if (productQuery.docs.isNotEmpty) {
        final productDoc = productQuery.docs.first;
        return {
          'id': productId,
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

  Future<Map<String, dynamic>> fetchProductInfo(String productId) async {
    final productQuery = await _firestore
        .collection('products')
        .where('id', isEqualTo: productId)
        .get();

    if (productQuery.docs.isNotEmpty) {
      final productData = productQuery.docs.first.data();
      final productName = productData['nama'] as String? ?? '';
      final productStock = productData['stok'] as int? ?? 0;
      final productPrice = productData['harga'] as int? ?? 0;

      return {'nama': productName, 'stok': productStock, 'harga': productPrice};
    }

    return {
      'nama': '',
      'stok': 0,
    };
  }
}
