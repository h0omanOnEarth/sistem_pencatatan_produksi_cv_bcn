import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionOrderDropDown extends StatefulWidget {
  final String? selectedPRO;
  final Function(String?) onChanged;
  late final TextEditingController tanggalProduksiController;

  ProductionOrderDropDown({required this.selectedPRO, required this.onChanged, required this.tanggalProduksiController});

  @override
  State<ProductionOrderDropDown> createState() => _ProductionOrderDropDownState();
}

class _ProductionOrderDropDownState extends State<ProductionOrderDropDown> {
  late QueryDocumentSnapshot _selectedDoc; // Menyimpan dokumen yang dipilih

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('production_orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> proItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          String productId = document['product_id'] ?? '';
          String proId = document['id'];
          String bomId = document['bom_id'];
          proItems.add(
            DropdownMenuItem<String>(
              value: proId,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: $proId | PRODUCT ID: $productId | BOM ID: $bomId',
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
              'Bill of Material',
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
                onChanged: (newValue) async {
                  widget.onChanged(newValue);
                  _selectedDoc = snapshot.data!.docs.firstWhere(
                    (document) => document['id'] == newValue,
                  );

                  final tanggalProduksiFirestore = _selectedDoc['tanggal_produksi'];
                  if (tanggalProduksiFirestore != null) {
                    final timestamp = tanggalProduksiFirestore as Timestamp;
                    final dateTime = timestamp.toDate();

                    final List<String> monthNames = [
                      "Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"
                    ];

                    final day = dateTime.day.toString();
                    final month = monthNames[dateTime.month - 1];
                    final year = dateTime.year.toString();

                    final formattedDate = '$month $day, $year';
                    widget.tanggalProduksiController.text = formattedDate;
                  }
                },
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
