import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';

class CustomerOrderChart extends StatelessWidget {
  const CustomerOrderChart({super.key});

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
              'Produk Berdasarkan Pesanan Pelanggan',
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
              future: fetchChartData(), // Mengambil data untuk chart
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
          )
        ],
      ),
    );
  }
}

Future<List<DataPoint>> fetchChartData() async {
  final firestore = FirebaseFirestore.instance;
  final querySnapshot = await firestore.collection('customer_orders').get();
  final data = querySnapshot.docs;

  final chartData = <String, double>{};
  for (final doc in data) {
    final detailSnapshot =
        await doc.reference.collection('detail_customer_orders').get();
    final detailData = detailSnapshot.docs;
    for (final detailDoc in detailData) {
      final productId = detailDoc['product_id'] as String;
      final quantity = detailDoc['jumlah'] as int;

      chartData.update(productId, (value) => value + quantity,
          ifAbsent: () => quantity.toDouble());
    }
  }

  final result = <DataPoint>[];
  for (final productId in chartData.keys) {
    final productInfo = await ProductService().getProductInfo(productId);
    final productName = productInfo?['nama'] as String;
    final value = chartData[productId];
    result.add(DataPoint(productName, value as double));
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
