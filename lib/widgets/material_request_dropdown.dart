import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/utils/format_date.dart';

class MaterialRequestDropdown extends StatefulWidget {
  final String? selectedMaterialRequest;
  final Function(String?) onChanged;
  final TextEditingController? tanggalPermintaanController;
  final TextEditingController? nomorPerintahProduksiController;
  final bool isEnabled;
  final String? mode;
  final String? feature;

  const MaterialRequestDropdown({
    Key? key,
    required this.selectedMaterialRequest,
    required this.onChanged,
    this.tanggalPermintaanController,
    this.nomorPerintahProduksiController,
    this.isEnabled = true,
    this.mode,
    this.feature,
  }) : super(key: key);

  @override
  State<MaterialRequestDropdown> createState() =>
      _MaterialRequestDropdownState();
}

class _MaterialRequestDropdownState extends State<MaterialRequestDropdown> {
  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
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
        InkWell(
          onTap: widget.isEnabled ? _showMaterialRequestDialog : null,
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
                    widget.selectedMaterialRequest ?? 'Select Material Request',
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
  }

  // Periksa status produksi dalam production_orders
  Future<bool> checkProductionStatus(String productionOrderId) async {
    DocumentSnapshot productionOrderSnapshot = await firestore
        .collection('production_orders')
        .doc(productionOrderId)
        .get();
    return productionOrderSnapshot.exists &&
        productionOrderSnapshot['status_pro'] == 'Dalam Proses' &&
        productionOrderSnapshot['status'] == 1;
  }

  Future<void> _showMaterialRequestDialog() async {
    final QuerySnapshot snapshot =
        await firestore.collection('material_requests').get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context, // Use the original context here
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Material Request'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: filterDocuments(snapshot),
              builder: (BuildContext context,
                  AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // or another loading indicator
                }

                List<QueryDocumentSnapshot> documents = snapshot.data!;

                documents.sort((a, b) {
                  DateTime dateA = a['tanggal_permintaan'].toDate();
                  DateTime dateB = b['tanggal_permintaan'].toDate();
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document = documents[index];
                    String materialRequestId = document['id'];
                    DateTime tanggalPermintaan =
                        document['tanggal_permintaan'].toDate();
                    String productionOrderId = document['production_order_id'];

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, materialRequestId);

                        // Call the onChanged callback with the selected value
                        widget.onChanged(materialRequestId);

                        // Update other fields based on selectedMaterialRequest if needed
                        if (widget.tanggalPermintaanController != null) {
                          final selectedDoc = snapshot.data!.firstWhere(
                              (doc) => doc['id'] == materialRequestId);
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
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $materialRequestId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Tanggal Permintaan: ${DateFormatter.formatDate(tanggalPermintaan)}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Production Order ID: $productionOrderId',
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
    ).then((selectedMaterialRequest) {
      if (selectedMaterialRequest != null) {
        // widget.onChanged(selectedMaterialRequest);

        // Update other fields based on selectedMaterialRequest if needed
        // ...
      }
    });
  }

  Future<List<QueryDocumentSnapshot>> filterDocuments(
      QuerySnapshot snapshot) async {
    List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

    List<QueryDocumentSnapshot> filteredDocuments = [];

    // Perform asynchronous operations in parallel using Future.wait
    await Future.wait(documents.map((document) async {
      bool isProductionInProgress = false;

      if (widget.feature == null) {
        // material transfer
        if (widget.mode == "add" && widget.isEnabled) {
          if (document['status'] == 1 &&
              document['status_mr'] == "Dalam Proses") {
            isProductionInProgress =
                await checkProductionStatus(document['production_order_id']);
          }
        } else {
          isProductionInProgress = true;
        }
      } else {
        // material usage
        if (widget.isEnabled) {
          if (document['status'] == 1 && document['status_mr'] == "Selesai") {
            isProductionInProgress =
                await checkProductionStatus(document['production_order_id']);
          }
        } else {
          isProductionInProgress = true;
        }
      }

      if (isProductionInProgress) {
        filteredDocuments.add(document);
      }
    }));

    return filteredDocuments;
  }
}
