import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialUsageDropdown extends StatefulWidget {
  final String? selectedMaterialUsage;
  final Function(String?) onChanged;
  final TextEditingController? namaBatchController;
  final TextEditingController? nomorPerintahProduksiController;

  const MaterialUsageDropdown({
    Key? key,
    required this.selectedMaterialUsage,
    required this.onChanged,
    this.namaBatchController,
    this.nomorPerintahProduksiController
  }) : super(key: key);

  @override
  State<MaterialUsageDropdown> createState() => _MaterialUsageDropdownState();
}

class _MaterialUsageDropdownState extends State<MaterialUsageDropdown> {
  String? selectedBatch; // Menyimpan nilai batch terpilih

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('material_usages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> materialUsageItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          String materialUsageId = document['id'];
          materialUsageItems.add(
            DropdownMenuItem<String>(
              value: materialUsageId,
              child: Text(
                materialUsageId,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penggunaan Bahan',
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
                value: widget.selectedMaterialUsage,
                items: materialUsageItems,
                onChanged: (newValue) async {
                  widget.onChanged(newValue);

                  // Ambil data batch dari Firestore berdasarkan selectedMaterialUsage
                  final batchData = await FirebaseFirestore.instance
                      .collection('material_usages')
                      .doc(newValue)
                      .get();

                  if (batchData.exists) {
                    // Jika data batch ada, isi namaBatchController dengan nilai batch
                    final batchValue = batchData['batch'] as String?;
                    if (widget.namaBatchController != null) {
                      widget.namaBatchController!.text = batchValue ?? '';
                    }
                    // Set selectedBatch untuk menyimpan nilainya
                    selectedBatch = batchValue;

                     if (widget.nomorPerintahProduksiController != null) {
                      widget.nomorPerintahProduksiController!.text = batchData['production_order_id'];
                    }

                  } else {
                    // Jika data batch tidak ditemukan, kosongkan namaBatchController
                    if (widget.namaBatchController != null) {
                      widget.namaBatchController!.text = '';
                    }
                    selectedBatch = null;
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
