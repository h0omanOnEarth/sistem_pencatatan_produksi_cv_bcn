import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/bahanService.dart';

class MaterialUsageChartCard extends StatelessWidget {
  const MaterialUsageChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Penggunaan Bahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 300, // Atur tinggi card sesuai kebutuhan Anda
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: fetchMaterialUsageChartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final chartData = snapshot.data as List<DataPoint>;
                  return PieChart(
                    PieChartData(
                      sections: chartData
                          .asMap()
                          .entries
                          .map(
                            (entry) => PieChartSectionData(
                              color: getColor(entry.key), // Warna sesuai indeks
                              value: entry.value.value,
                              title:
                                  '${entry.value.label}\n${entry.value.value.toStringAsFixed(2)}',
                            ),
                          )
                          .toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<DataPoint>> fetchMaterialUsageChartData() async {
  final firestore = FirebaseFirestore.instance;
  final querySnapshot = await firestore.collection('material_usages').get();
  final data = querySnapshot.docs;

  final chartData = <String, double>{};
  for (final doc in data) {
    final detailSnapshot =
        await doc.reference.collection('detail_material_usages').get();
    final detailData = detailSnapshot.docs;
    for (final detailDoc in detailData) {
      final materialId = detailDoc['material_id'] as String;
      final quantity = detailDoc['jumlah'] as int;

      chartData.update(materialId, (value) => value + quantity,
          ifAbsent: () => quantity.toDouble());
    }
  }

  final result = <DataPoint>[];
  for (final materialId in chartData.keys) {
    final materialInfo = await MaterialService().fetchMaterialInfo(materialId);
    final materialName = materialInfo['nama'] as String;
    final value = chartData[materialId];
    result.add(DataPoint(materialName, value as double));
  }
  return result;
}

Color getColor(int index) {
  // Atur warna sesuai preferensi Anda, misalnya:
  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];
  return colors[index % colors.length];
}

class DataPoint {
  final String label;
  final double value;

  DataPoint(this.label, this.value);
}
