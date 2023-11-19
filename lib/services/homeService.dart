import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchFirestoreData(
      List<String> collections) async {
    final data = <String, dynamic>{};

    for (final collectionName in collections) {
      final querySnapshot = await firestore.collection(collectionName).get();
      final collectionData =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      if (collectionName == 'production_orders') {
        // Filter production_orders dengan status_pro == 'Dalam Proses'
        final filteredProductionOrders = collectionData
            .where((order) => order['status_pro'] == 'Dalam Proses')
            .toList();
        data[collectionName] = filteredProductionOrders;

        // Add the count for 'production_orders' with 'Dalam Proses' status to the data map
        data['${collectionName}_count'] = filteredProductionOrders.length;
      } else {
        data[collectionName] = collectionData;
        // Add the count for other collections to the data map
        data['${collectionName}_count'] = collectionData.length;
      }
    }

    return data;
  }
}
