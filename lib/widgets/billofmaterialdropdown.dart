import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillOfMaterialDropDown extends StatelessWidget {
  final String? selectedBOM;
  final Function(String?) onChanged;

  BillOfMaterialDropDown({required this.selectedBOM, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bill_of_materials').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> bomItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
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
                  'ID: $bomId, Product: $productId, Versi: $versiBom',
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
                onChanged: (newValue) {
                  onChanged(newValue);
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
