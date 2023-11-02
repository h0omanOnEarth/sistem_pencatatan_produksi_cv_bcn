import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionOrderDropDown extends StatefulWidget {
  final String? selectedPRO;
  final Function(String?) onChanged;
  late final TextEditingController? tanggalProduksiController;
  late final TextEditingController? kodeProdukController;
  late final TextEditingController? namaProdukController;
  late final TextEditingController? kodeBomController;
  final bool isEnabled;

  ProductionOrderDropDown({
    super.key,
    required this.selectedPRO,
    required this.onChanged,
    this.tanggalProduksiController,
    this.kodeProdukController,
    this.namaProdukController,
    this.kodeBomController,
    this.isEnabled = true,
  });

  @override
  State<ProductionOrderDropDown> createState() =>
      _ProductionOrderDropDownState();
}

class _ProductionOrderDropDownState extends State<ProductionOrderDropDown> {
  late QueryDocumentSnapshot _selectedDoc; // Menyimpan dokumen yang dipilih
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore

  Future<String?> getProductName(String productId) async {
    try {
      final productQuery = await firestore
          .collection('products')
          .where('id',
              isEqualTo:
                  productId) // Ganti 'product_id' dengan nama field yang sesuai
          .limit(1) // Batasi hasil ke satu dokumen (jika ada banyak yang cocok)
          .get();

      if (productQuery.docs.isNotEmpty) {
        final productName = productQuery.docs.first['nama'] as String?;
        return productName;
      }
      return null;
    } catch (e) {
      print('Error fetching product name: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('production_orders')
          .where(
            'status',
            isEqualTo: widget.isEnabled
                ? 1
                : null, // Filter status hanya saat isEnabled true
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> proItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          String proId = document['id'];
          proItems.add(
            DropdownMenuItem<String>(
              value: proId,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proId,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perintah Produksi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: DropdownButtonFormField<String>(
                value: widget.selectedPRO,
                items: proItems,
                onChanged: widget.isEnabled
                    ? (newValue) async {
                        widget.onChanged(newValue);
                        _selectedDoc = snapshot.data!.docs.firstWhere(
                          (document) => document['id'] == newValue,
                        );

                        final tanggalProduksiFirestore =
                            _selectedDoc['tanggal_produksi'];
                        if (tanggalProduksiFirestore != null) {
                          final timestamp =
                              tanggalProduksiFirestore as Timestamp;
                          final dateTime = timestamp.toDate();

                          final List<String> monthNames = [
                            "Januari",
                            "Februari",
                            "Maret",
                            "April",
                            "Mei",
                            "Juni",
                            "Juli",
                            "Agustus",
                            "September",
                            "Oktober",
                            "November",
                            "Desember"
                          ];

                          final day = dateTime.day.toString();
                          final month = monthNames[dateTime.month - 1];
                          final year = dateTime.year.toString();

                          final formattedDate = '$month $day, $year';
                          widget.tanggalProduksiController?.text =
                              formattedDate;
                        }
                        widget.kodeProdukController?.text =
                            _selectedDoc['product_id'];
                        final productName =
                            await getProductName(_selectedDoc['product_id']);
                        widget.namaProdukController?.text = productName!;
                        widget.kodeBomController?.text = _selectedDoc['bom_id'];
                        widget.kodeProdukController?.text =
                            _selectedDoc['product_id'];
                      }
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
