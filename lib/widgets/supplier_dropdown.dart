import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierDropdown extends StatefulWidget {
  final String? selectedSupplier;
  final Function(String?) onChanged;
  final TextEditingController? kodeSupplierController;
  final bool isEnabled;

  const SupplierDropdown({
    super.key,
    required this.selectedSupplier,
    required this.onChanged,
    this.kodeSupplierController,
    this.isEnabled = true,
  });

  @override
  State<SupplierDropdown> createState() => _SupplierDropdownState();
}

class _SupplierDropdownState extends State<SupplierDropdown> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> supplierItems = [];

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Filter dan urutkan data secara lokal
        documents = documents.where((document) {
          if (widget.isEnabled) {
            // Jika isEnabled true, tambahkan pemeriksaan status pesanan pengiriman
            return document['status'] == 1;
          } else {
            // Jika isEnabled false, tampilkan semua data
            return true;
          }
        }).toList();

        for (QueryDocumentSnapshot document in documents) {
          String supplierName = document['nama'] ?? '';
          String supplierId = document['id'];
          supplierItems.add(
            DropdownMenuItem<String>(
              value: supplierId,
              child: Text(
                supplierName,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supplier',
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
                value: widget.selectedSupplier,
                items: supplierItems,
                onChanged: widget.isEnabled
                    ? (newValue) {
                        widget.onChanged(newValue);
                        if (widget.kodeSupplierController != null) {
                          widget.kodeSupplierController!.text = newValue ?? '';
                        }
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
