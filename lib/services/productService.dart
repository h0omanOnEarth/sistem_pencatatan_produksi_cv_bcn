import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService{

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

}