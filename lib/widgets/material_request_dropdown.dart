import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialRequestDropdown extends StatelessWidget {
  final String? selectedMaterialRequest;
  final Function(String?) onChanged;
  final TextEditingController? tanggalPermintaanController;
  final bool isEnabled;

  const MaterialRequestDropdown({
    Key? key,
    required this.selectedMaterialRequest,
    required this.onChanged,
    this.tanggalPermintaanController,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('material_requests')
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

        List<DropdownMenuItem<String>> materialRequestItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          String materialRequestId = document['id'];
          materialRequestItems.add(
            DropdownMenuItem<String>(
              value: materialRequestId,
              child: Text(
                materialRequestId,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permintaan Bahan',
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
                value: selectedMaterialRequest,
                items: materialRequestItems,
                onChanged: isEnabled
                    ? (newValue) {
                        onChanged(newValue);
                        if (tanggalPermintaanController != null) {
                          final selectedDoc = snapshot.data!.docs
                              .firstWhere((doc) => doc['id'] == newValue);
                          var tanggalPermintaanFirestore =
                              selectedDoc['tanggal_permintaan'];
                          String tanggalPermintaan = '';

                          if (tanggalPermintaanFirestore != null) {
                            final timestamp =
                                tanggalPermintaanFirestore as Timestamp;
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

                            tanggalPermintaan = '$day $month $year';
                          }

                          tanggalPermintaanController!.text = tanggalPermintaan;
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
