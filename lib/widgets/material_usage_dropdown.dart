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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // Indikator loading
                )
              : DropdownButtonFormField<String>(
                  value: widget.selectedMaterialUsage,
                  items: materialUsageIds
                      .map(
                        (materialUsageId) => DropdownMenuItem<String>(
                          value: materialUsageId,
                          child: Text(
                            materialUsageId,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
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
                              widget.namaBatchController!.text =
                                  batchValue ?? '';
                            }
                            selectedBatch = batchValue;

                            if (widget.nomorPerintahProduksiController !=
                                null) {
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
  }
}
