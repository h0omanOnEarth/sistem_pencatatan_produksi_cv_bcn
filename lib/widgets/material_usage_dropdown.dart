import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialUsageDropdown extends StatefulWidget {
  final String? selectedMaterialUsage;
  final Function(String?) onChanged;
  final TextEditingController? namaBatchController;
  final TextEditingController? nomorPerintahProduksiController;
  final bool isEnabled;
  final String? feature;

  const MaterialUsageDropdown(
      {Key? key,
      required this.selectedMaterialUsage,
      required this.onChanged,
      this.namaBatchController,
      this.nomorPerintahProduksiController,
      this.isEnabled = true,
      this.feature})
      : super(key: key);

  @override
  State<MaterialUsageDropdown> createState() => _MaterialUsageDropdownState();
}

class _MaterialUsageDropdownState extends State<MaterialUsageDropdown> {
  String? selectedBatch; // Menyimpan nilai batch terpilih
  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('material_usages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Filter dan urutkan data secara lokal
        documents = documents.where((document) {
          if (widget.isEnabled && widget.feature != null) {
            // Jika isEnabled true, tambahkan pemeriksaan status pesanan pengiriman
            return document['status'] == 1 &&
                document['status_mu'] == "Selesai" &&
                document['batch'] == "Pencetakan";
          } else if (widget.isEnabled) {
            return document['status'] == 1 &&
                document['status_mu'] == "Selesai";
          } else {
            // Jika isEnabled false, tampilkan semua data
            return true;
          }
        }).toList();

        documents.sort((a, b) {
          DateTime dateA = a['tanggal_penggunaan'].toDate();
          DateTime dateB = b['tanggal_penggunaan'].toDate();
          return dateB.compareTo(dateA);
        });

        List<DropdownMenuItem<String>> materialUsageItems = [];

        for (QueryDocumentSnapshot document in documents) {
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
