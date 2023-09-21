import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialService{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getMaterialInfo(String materialId) async {
  try {
    final productQuery = await firestore
        .collection('materials')
        .where('id', isEqualTo: materialId)
        .get();

    if (productQuery.docs.isNotEmpty) {
      final productDoc = productQuery.docs.first;
      return {
        'id': materialId,
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