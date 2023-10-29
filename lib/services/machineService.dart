import 'package:cloud_firestore/cloud_firestore.dart';

class MachineService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchMachineInfo(String machineId) async {
    final machineQuery = await firestore
        .collection('machines')
        .where('id', isEqualTo: machineId)
        .get();

    if (machineQuery.docs.isNotEmpty) {
      final machineData = machineQuery.docs.first.data();
      final machineName = machineData['nama'] as String? ?? '';

      return {
        'nama': machineName,
      };
    }

    return {
      'nama': '',
    };
  }
}
