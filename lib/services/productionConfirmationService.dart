
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionConfirmationService{

   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getProductionConfirmationInfo(String productionConfId) async {
  try {
    final productQuery = await _firestore
        .collection('production_confirmations')
        .where('id', isEqualTo: productionConfId)
        .get();

    if (productQuery.docs.isNotEmpty) {
      final productDoc = productQuery.docs.first;
      return {
        'id': productionConfId,
        'tanggalKonfirmasi': productDoc['tanggal_konfirmasi'] as Timestamp,
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