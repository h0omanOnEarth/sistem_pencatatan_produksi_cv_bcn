// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/utils/format_date.dart';

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
            InkWell(
              onTap:
                  widget.isEnabled ? _showProductionConfirmationDialog : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.selectedProductionConfirmationDropdown ??
                            'Select Production Confirmation',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showProductionConfirmationDialog() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('production_confirmations')
        .get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Production Confirmation'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents = documents.where((document) {
                  if (widget.isEnabled) {
                    return document['status'] == 1 &&
                        document['status_prc'] == "Dalam Proses";
                  } else {
                    return true;
                  }
                }).toList();

                documents.sort((a, b) {
                  DateTime dateA = a['tanggal_konfirmasi'].toDate();
                  DateTime dateB = b['tanggal_konfirmasi'].toDate();
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document = documents[index];
                    String productionConfirmationId = document['id'];
                    String tanggalKonfirmasi = DateFormatter.formatDate(
                      document['tanggal_konfirmasi'].toDate(),
                    );
                    String total = document['total'].toString();
                    String catatan = document['catatan'];
                    String statusPrc = document['status_prc'];

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, productionConfirmationId);

                        // Call the onChanged callback with the selected value
                        widget.onChanged(productionConfirmationId);

                        // Update other fields based on selected value if needed
                        if (widget.tanggalKonfirmasiController != null) {
                          widget.tanggalKonfirmasiController!.text =
                              tanggalKonfirmasi;
                        }
                        // Add other controllers if needed
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $productionConfirmationId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Tanggal Konfirmasi: $tanggalKonfirmasi',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Total: $total',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Catatan: $catatan',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Status PRC: $statusPrc',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    ).then((selectedProductionConfirmation) {
      if (selectedProductionConfirmation != null) {
        widget.onChanged(selectedProductionConfirmation);
      }
    });
  }
}
