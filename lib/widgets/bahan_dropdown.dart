import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Buat ValueNotifier khusus untuk BahanDropdown
ValueNotifier<String?> selectedBahanNotifier = ValueNotifier<String?>(null);

class BahanDropdown extends StatefulWidget {
  final TextEditingController namaBahanController;
  final TextEditingController? satuanBahanController;
  final String? bahanId;
  final bool isEnabled;

  const BahanDropdown({
    super.key,
    required this.namaBahanController,
    this.bahanId,
    this.satuanBahanController,
    this.isEnabled = true,
  });

  @override
  _BahanDropdownState createState() => _BahanDropdownState();
}

class _BahanDropdownState extends State<BahanDropdown> {
  late String? dropdownValue;

  @override
  void initState() {
    super.initState();
    if (widget.bahanId != null) {
      selectedBahanNotifier.value = widget.bahanId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedBahanNotifier,
      builder: (context, selectedBahan, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bahan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('materials')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> materialItems = [];

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
                  String materialId = document['id'];
                  String materialName = document['nama'];
                  // Filter nama tertentu (misalnya, 'materialXXX')
                  if (materialId != 'materialXXX') {
                    materialItems.add(
                      DropdownMenuItem<String>(
                        value: materialId,
                        child: Text(
                          materialName,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }
                }

                String? initialValue = selectedBahan;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: initialValue,
                    items: materialItems,
                    onChanged: widget.isEnabled
                        ? (newValue) {
                            // Periksa isEnabled
                            selectedBahanNotifier.value = newValue;
                            final selectedMaterial =
                                snapshot.data!.docs.firstWhere(
                              (document) => document['id'] == newValue,
                            );
                            widget.namaBahanController.text =
                                selectedMaterial['id'] ?? '';
                            widget.satuanBahanController?.text =
                                selectedMaterial['satuan'] ?? '';
                          }
                        : null, // Nonaktifkan dropdown jika isEnabled adalah false
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
                );
              },
            ),
          ],
        );
      },
    );
  }
}
