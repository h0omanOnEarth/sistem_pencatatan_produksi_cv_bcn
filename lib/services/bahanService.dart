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

Future<Map<String, dynamic>> fetchMaterialInfo(String materialId) async {
    final materialQuery = await firestore
    .collection('materials')
    .where('id', isEqualTo: materialId)
    .get();


  if (materialQuery.docs.isNotEmpty) {
    final materialData = materialQuery.docs.first.data();
    final materialName = materialData['nama'] as String? ?? '';
    final materialStock = materialData['stok'] as int? ?? 0;

    return {
      'nama': materialName,
      'stok': materialStock,
    };
  }

  return {
    'nama': '',
    'stok': 0,
  };
}


}