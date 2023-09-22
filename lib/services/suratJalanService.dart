import 'package:cloud_firestore/cloud_firestore.dart';

class SuratJalanService{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> generateNextShipmentId() async {
    final shipmentsRef = firestore.collection('shipments');
    final QuerySnapshot snapshot = await shipmentsRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int shipmentCount = 1;

    while (true) {
      final nextShipmentId = 'SHP${shipmentCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextShipmentId)) {
        return nextShipmentId;
      }
      shipmentCount++;
    }
  }
  
}