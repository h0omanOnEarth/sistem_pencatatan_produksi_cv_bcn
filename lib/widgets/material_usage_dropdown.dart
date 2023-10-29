import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialUsageDropdown extends StatefulWidget {
  final String? selectedMaterialUsage;
  final Function(String?) onChanged;
  final TextEditingController? namaBatchController;
  final TextEditingController? nomorPerintahProduksiController;
  final bool isEnabled;

  const MaterialUsageDropdown({
    Key? key,
    required this.selectedMaterialUsage,
    required this.onChanged,
    this.namaBatchController,
    this.nomorPerintahProduksiController,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<MaterialUsageDropdown> createState() => _MaterialUsageDropdownState();
}

class _MaterialUsageDropdownState extends State<MaterialUsageDropdown> {
  String? selectedBatch; // Menyimpan nilai batch terpilih

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('material_usages').snapshots(),
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
                onChanged: widget.isEnabled
                    ? (newValue) async {
                        widget.onChanged(newValue);

                        final batchData = await FirebaseFirestore.instance
                            .collection('material_usages')
                            .doc(newValue)
                            .get();

                        if (batchData.exists) {
                          final batchValue = batchData['batch'] as String?;
                          if (widget.namaBatchController != null) {
                            widget.namaBatchController!.text = batchValue ?? '';
                          }
                          selectedBatch = batchValue;

                          if (widget.nomorPerintahProduksiController != null) {
                            widget.nomorPerintahProduksiController!.text =
                                batchData['production_order_id'];
                          }
                        } else {
                          if (widget.namaBatchController != null) {
                            widget.namaBatchController!.text = '';
                          }
                          selectedBatch = null;
                        }
                      }
                    : null, // Menonaktifkan dropdown jika isEnabled false
                isExpanded: true,
                autovalidateMode: widget.isEnabled
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode
                        .disabled, // Mengatur validasi sesuai isEnabled
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
