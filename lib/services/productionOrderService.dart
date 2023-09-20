import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> findProductionOrderId(String materialUsageId) async {
    try {
      final materialUsageDoc =
          await _firestore.collection('material_usages').doc(materialUsageId).get();

      return materialUsageDoc['production_order_id'] as String?;
    } catch (e) {
      print('Error finding production order ID: $e');
      return null;
    }
  }

Future<Map<String, dynamic>?> getProductInfo(String productId) async {
  try {
    final productQuery = await _firestore
        .collection('products')
        .where('id', isEqualTo: productId)
        .get();

    if (productQuery.docs.isNotEmpty) {
      final productDoc = productQuery.docs.first;
      return {
        'product_id': productId,
        'product_name': productDoc['nama'] as String,
      };
    } else {
      return null;
    }
  } catch (e) {
    print('Error getting product info: $e');
    return null;
  }
}

  Future<Map<String, dynamic>?> getProductInfoForProductionOrder(
      String productionOrderId) async {
    try {
      final productionOrderDoc = await _firestore
          .collection('production_orders')
          .doc(productionOrderId)
          .get();

      if (productionOrderDoc.exists) {
        final productId = productionOrderDoc['product_id'] as String;
        return await getProductInfo(productId);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting product info for production order: $e');
      return null;
    }
  }
}
