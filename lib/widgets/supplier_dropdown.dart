import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierDropdown extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('suppliers')
          .where(
            'status',
            isEqualTo:
                isEnabled ? 1 : null, // Filter status hanya saat isEnabled true
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> supplierItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
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
                value: selectedSupplier,
                items: supplierItems,
                onChanged: isEnabled
                    ? (newValue) {
                        onChanged(newValue);
                        if (kodeSupplierController != null) {
                          kodeSupplierController!.text = newValue ?? '';
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
