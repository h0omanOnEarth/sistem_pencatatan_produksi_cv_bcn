import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';

class ProductsChart extends StatelessWidget {
  const ProductsChart({super.key});

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
              'Ketersediaan Barang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: fetchProductChartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final chartData = snapshot.data as List<DataPoint>;
                  const maxSectorsToShow = 4; // Jumlah maksimal sektor yang akan ditampilkan
                  final otherData = chartData.sublist(maxSectorsToShow);
                  final totalValue = calculateTotalValue(otherData);
                  final dataToShow = chartData.sublist(0, maxSectorsToShow);

                  // Hitung nilai "Lainnya" sebagai persentase total
                  final otherValue = totalValue * 0.1; // Misalnya, "Lainnya" adalah 10% dari total

                  if (totalValue > 0) {
                    dataToShow.add(DataPoint("Lainnya", otherValue));
                  }

                  return PieChart(
                    PieChartData(
                      sections: dataToShow
                          .asMap()
                          .entries
                          .map(
                            (entry) => PieChartSectionData(
                              color: getColor(entry.key),
                              value: entry.value.value,
                              titlePositionPercentageOffset: 0.7,
                              title: '${entry.value.label}\n${entry.value.value.toStringAsFixed(2)}',
                              radius: 60,
                            ),
                          )
                          .toList(),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
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

Future<List<DataPoint>> fetchProductChartData() async {
  final productService = ProductService(); // Ganti dengan service produk yang sesuai
  final firestore = FirebaseFirestore.instance;
  final querySnapshot = await firestore.collection('products').get(); // Ubah menjadi 'products'
  final data = querySnapshot.docs;

  final chartData = <DataPoint>[];
  for (final doc in data) {
    final id = doc['id'] as String;
    final productInfo = await productService.fetchProductInfo(id); // Ganti dengan fetchProductInfo yang sesuai

    final productName = productInfo['nama'] as String;
    final stok = productInfo['stok'] as double;

    chartData.add(DataPoint(productName, stok));
  }
  return chartData;
}

Color getColor(int index) {
  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.cyan
  ];
  return colors[index % colors.length];
}

class DataPoint {
  final String label;
  final double value;

  DataPoint(this.label, this.value);
}

double calculateTotalValue(List<DataPoint> data) {
  double totalValue = 0;
  for (final point in data) {
    totalValue += point.value;
  }
  return totalValue;
}
