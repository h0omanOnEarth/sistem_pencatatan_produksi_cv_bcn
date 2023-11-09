import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialRequestDropdown extends StatefulWidget {
  final String? selectedMaterialRequest;
  final Function(String?) onChanged;
  final TextEditingController? tanggalPermintaanController;
  final TextEditingController? nomorPerintahProduksiController;
  final bool isEnabled;
  final String? mode;
  final String? feature;

  const MaterialRequestDropdown(
      {Key? key,
      required this.selectedMaterialRequest,
      required this.onChanged,
      this.tanggalPermintaanController,
      this.nomorPerintahProduksiController,
      this.isEnabled = true,
      this.mode,
      this.feature})
      : super(key: key);

  @override
  State<MaterialRequestDropdown> createState() =>
      _MaterialRequestDropdownState();
}

class _MaterialRequestDropdownState extends State<MaterialRequestDropdown> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('material_requests')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        if (widget.feature == null) {
          //material transfer
          // Filter dan urutkan data secara lokal
          documents = documents.where((document) {
            if (widget.mode == "add") {
              // Jika isEnabled true, tambahkan pemeriksaan status pesanan pengiriman
              return document['status'] == 1 &&
                  document['status_mr'] == "Dalam Proses";
            } else {
              // Jika isEnabled false, tampilkan semua data
              return true;
            }
          }).toList();
        } else {
          //material usage
          documents = documents.where((document) {
            if (widget.isEnabled == true) {
              // Jika isEnabled true, tambahkan pemeriksaan status pesanan pengiriman
              return document['status'] == 1 &&
                  document['status_mr'] == "Selesai";
            } else {
              // Jika isEnabled false, tampilkan semua data
              return true;
            }
          }).toList();
        }

        documents.sort((a, b) {
          DateTime dateA = a['tanggal_permintaan'].toDate();
          DateTime dateB = b['tanggal_permintaan'].toDate();
          return dateB.compareTo(dateA);
        });

        List<DropdownMenuItem<String>> materialRequestItems = [];

        for (QueryDocumentSnapshot document in documents) {
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
                value: widget.selectedMaterialRequest,
                items: materialRequestItems,
                onChanged: widget.isEnabled
                    ? (newValue) {
                        widget.onChanged(newValue);
                        if (widget.tanggalPermintaanController != null) {
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

                          widget.tanggalPermintaanController!.text =
                              tanggalPermintaan;

                          if (widget.nomorPerintahProduksiController != null) {
                            widget.nomorPerintahProduksiController!.text =
                                selectedDoc['production_order_id'];
                          }
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
