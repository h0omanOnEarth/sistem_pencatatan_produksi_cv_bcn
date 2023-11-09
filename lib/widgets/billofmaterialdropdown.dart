import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillOfMaterialDropDown extends StatelessWidget {
  final String? selectedBOM;
  final Function(String?) onChanged;
  final bool isEnabled;

  BillOfMaterialDropDown({
    required this.selectedBOM,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('bill_of_materials');

    if (isEnabled) {
      query =
          query.where('status', isEqualTo: 1).where('status_bom', isEqualTo: 1);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> bomItems = [];

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Filter dan urutkan data secara lokal
        documents = documents.where((document) {
          if (isEnabled) {
            // Jika isEnabled true, tambahkan pemeriksaan status pesanan pengiriman
            return document['status_bom'] == 1 && document['status'] == 1;
          } else {
            // Jika isEnabled false, tampilkan semua data
            return true;
          }
        }).toList();

        documents.sort((a, b) {
          DateTime dateA = a['tanggal_pembuatan'].toDate();
          DateTime dateB = b['tanggal_pembuatan'].toDate();
          return dateB.compareTo(dateA);
        });

        for (QueryDocumentSnapshot document in documents) {
          String productId = document['product_id'] ?? '';
          String bomId = document['id'];
          String versiBom = document['versi_bom'].toString();
          bomItems.add(
            DropdownMenuItem<String>(
              value: bomId,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$bomId, $productId, $versiBom',
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
                value: selectedBOM,
                items: bomItems,
                onChanged: isEnabled
                    ? (newValue) {
                        onChanged(newValue);
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
