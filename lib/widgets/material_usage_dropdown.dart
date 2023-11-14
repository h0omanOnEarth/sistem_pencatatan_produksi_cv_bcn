import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialUsageDropdown extends StatefulWidget {
  final String? selectedMaterialUsage;
  final Function(String?) onChanged;
  final TextEditingController? namaBatchController;
  final TextEditingController? nomorPerintahProduksiController;
  final bool isEnabled;
  final String? feature;

  const MaterialUsageDropdown({
    Key? key,
    required this.selectedMaterialUsage,
    required this.onChanged,
    this.namaBatchController,
    this.nomorPerintahProduksiController,
    this.isEnabled = true,
    this.feature,
  }) : super(key: key);

  @override
  State<MaterialUsageDropdown> createState() => _MaterialUsageDropdownState();
}

class _MaterialUsageDropdownState extends State<MaterialUsageDropdown> {
  String? selectedBatch; // Menyimpan nilai batch terpilih
  final firestore = FirebaseFirestore.instance;
  List<String> materialUsageIds = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data produksi yang sedang dalam proses
    if (widget.isEnabled == true) {
      fetchMaterialUsageWithStatusPro();
    } else {
      fetchMaterialUsageEdit();
    }
  }

  Future<void> _showMaterialUsageDialog() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('material_usages').get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Material Usage'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents.sort((a, b) {
                  DateTime dateA = a['tanggal_penggunaan'].toDate();
                  DateTime dateB = b['tanggal_penggunaan'].toDate();
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document = documents[index];
                    String materialUsageId = document['id'];
                    DateTime tanggalPenggunaan =
                        document['tanggal_penggunaan'].toDate();
                    String productionOrderId = document['production_order_id'];
                    String materialRequestId = document['material_request_id'];
                    String batch = document['batch'];
                    String statusMu = document['status_mu'];

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, materialUsageId);

                        // Call the onChanged callback with the selected value
                        widget.onChanged(materialUsageId);

                        // Update other fields based on selectedMaterialUsage if needed
                        if (widget.namaBatchController != null) {
                          widget.namaBatchController!.text = batch;
                        }
                        if (widget.nomorPerintahProduksiController != null) {
                          widget.nomorPerintahProduksiController!.text =
                              productionOrderId;
                        }
                        // Add other controllers if needed

                        selectedBatch = batch;
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $materialUsageId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Tanggal Penggunaan: ${tanggalPenggunaan.toLocal()}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Production Order ID: $productionOrderId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Material Request ID: $materialRequestId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Batch: $batch',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Status MU: $statusMu',
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
    ).then((selectedMaterialUsage) {
      if (selectedMaterialUsage != null) {
        widget.onChanged(selectedMaterialUsage);

        // Update other fields based on selectedMaterialUsage if needed
        // ...
      }
    });
  }

  void fetchMaterialUsageEdit() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot materialUsageSnapshot =
        await firestore.collection('material_usages').get();

    List<String> inProgressMaterialUsageIds = [];

    for (QueryDocumentSnapshot document in materialUsageSnapshot.docs) {
      inProgressMaterialUsageIds.add(document['id']);
    }

    materialUsageIds = inProgressMaterialUsageIds;

    setState(() {
      isLoading = false;
    }); // Update the view after data is fetched and sorted
  }

  void fetchMaterialUsageWithStatusPro() async {
    setState(() {
      isLoading = true;
    });

    Query materialUsageQuery = firestore.collection('material_usages');

    if (widget.feature != null) {
      materialUsageQuery = materialUsageQuery
          .where('status_mu', isEqualTo: 'Selesai')
          .where('batch', isEqualTo: 'Pencetakan')
          .where('status', isEqualTo: 1);
    }

    if (widget.feature == null) {
      materialUsageQuery = materialUsageQuery
          .where('status_mu', isEqualTo: 'Selesai')
          .where('status', isEqualTo: 1);
    }

    QuerySnapshot materialUsageSnapshot = await materialUsageQuery.get();
    List<String> inProgressMaterialUsageIds = [];

    for (QueryDocumentSnapshot document in materialUsageSnapshot.docs) {
      String productionOrderId = document['production_order_id'];
      bool isInProgress = await checkProductionStatus(productionOrderId);
      if (isInProgress) {
        inProgressMaterialUsageIds.add(document['id']);
      }
    }

    // Sort inProgressMaterialUsageIds based on tanggal_penggunaan in descending order
    inProgressMaterialUsageIds.sort((a, b) {
      final materialUsageA =
          materialUsageSnapshot.docs.firstWhere((doc) => doc['id'] == a);
      final materialUsageB =
          materialUsageSnapshot.docs.firstWhere((doc) => doc['id'] == b);
      final dateA = materialUsageA['tanggal_penggunaan'].toDate();
      final dateB = materialUsageB['tanggal_penggunaan'].toDate();
      return dateB.compareTo(dateA);
    });

    materialUsageIds = inProgressMaterialUsageIds;

    setState(() {
      isLoading = false;
    }); // Update the view after data is fetched and sorted
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

  @override
  Widget build(BuildContext context) {
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
        InkWell(
          onTap: widget.isEnabled ? _showMaterialUsageDialog : null,
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
                    widget.selectedMaterialUsage ?? 'Select Material Usage',
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
}
