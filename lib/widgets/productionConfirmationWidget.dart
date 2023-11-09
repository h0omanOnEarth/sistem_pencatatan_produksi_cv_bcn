// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionConfirmationDropDown extends StatefulWidget {
  final String? selectedProductionConfirmationDropdown;
  final Function(String?) onChanged;
  final TextEditingController? tanggalKonfirmasiController;
  final bool isEnabled;

  const ProductionConfirmationDropDown({
    Key? key,
    required this.selectedProductionConfirmationDropdown,
    required this.onChanged,
    this.tanggalKonfirmasiController,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<ProductionConfirmationDropDown> createState() =>
      _ProductionConfirmationDropDownState();
}

class _ProductionConfirmationDropDownState
    extends State<ProductionConfirmationDropDown> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('production_confirmations')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Filter dan urutkan data secara lokal
        documents = documents.where((document) {
          if (widget.isEnabled) {
            // Jika isEnabled true, tambahkan pemeriksaan status pesanan pengiriman
            return document['status'] == 1 &&
                document['status_prc'] == "Dalam Proses";
          } else {
            // Jika isEnabled false, tampilkan semua data
            return true;
          }
        }).toList();

        documents.sort((a, b) {
          DateTime dateA = a['tanggal_konfirmasi'].toDate();
          DateTime dateB = b['tanggal_konfirmasi'].toDate();
          return dateB.compareTo(dateA);
        });

        List<DropdownMenuItem<String>> productionConfirmationItems = [];

        for (QueryDocumentSnapshot document in documents) {
          String productionConfirmationId = document['id'];
          productionConfirmationItems.add(
            DropdownMenuItem<String>(
              value: productionConfirmationId,
              child: Text(
                productionConfirmationId,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konfirmasi Produksi',
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
                value: widget.selectedProductionConfirmationDropdown,
                items: productionConfirmationItems,
                onChanged: widget.isEnabled
                    ? (newValue) {
                        widget.onChanged(newValue);
                        if (widget.tanggalKonfirmasiController != null) {
                          final selectedDoc = snapshot.data!.docs
                              .firstWhere((doc) => doc['id'] == newValue);
                          var tanggalKonfirmasiFirestore =
                              selectedDoc['tanggal_konfirmasi'];
                          String tanggalPermintaan = '';

                          if (tanggalKonfirmasiFirestore != null) {
                            final timestamp =
                                tanggalKonfirmasiFirestore as Timestamp;
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

                          widget.tanggalKonfirmasiController!.text =
                              tanggalPermintaan;
                        }
                      }
                    : null,
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
