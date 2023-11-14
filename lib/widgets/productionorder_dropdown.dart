import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';

class ProductionOrderDropDown extends StatefulWidget {
  final String? selectedPRO;
  final Function(String?) onChanged;
  final TextEditingController? tanggalProduksiController;
  final TextEditingController? kodeProdukController;
  final TextEditingController? namaProdukController;
  final TextEditingController? kodeBomController;
  final bool isEnabled;

  ProductionOrderDropDown({
    Key? key,
    required this.selectedPRO,
    required this.onChanged,
    this.tanggalProduksiController,
    this.kodeProdukController,
    this.namaProdukController,
    this.kodeBomController,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<ProductionOrderDropDown> createState() =>
      _ProductionOrderDropDownState();
}

class _ProductionOrderDropDownState extends State<ProductionOrderDropDown> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore

  Future<void> _showProductionOrderDialog() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('production_orders').get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Production Order'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents.sort((a, b) {
                  DateTime dateA = a['tanggal_rencana'].toDate();
                  DateTime dateB = b['tanggal_rencana'].toDate();
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document = documents[index];
                    String productionOrderId = document['id'];
                    DateTime tanggalRencana =
                        document['tanggal_rencana'].toDate();
                    DateTime tanggalProduksi =
                        document['tanggal_produksi'].toDate();
                    String productId = document['product_id'];
                    String bomId = document['bom_id'];
                    String statusPro = document['status_pro'];

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, productionOrderId);

                        // Call the onChanged callback with the selected value
                        widget.onChanged(productionOrderId);

                        // Update other fields based on selectedPRO if needed
                        if (widget.tanggalProduksiController != null) {
                          final timestamp =
                              document['tanggal_produksi'] as Timestamp;
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

                          final formattedDate = '$month $day, $year';
                          widget.tanggalProduksiController!.text =
                              formattedDate;
                        }

                        widget.kodeProdukController?.text = productId;
                        widget.kodeBomController?.text = bomId;

                        // Retrieve and set product name
                        ProductService productService = ProductService();
                        productService
                            .getProductInfo(productId)
                            .then((productName) {
                          if (productName != null &&
                              widget.namaProdukController != null) {
                            widget.namaProdukController!.text =
                                productName['nama'];
                          }
                        });
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $productionOrderId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Tanggal Rencana: ${tanggalRencana.toLocal()}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Tanggal Produksi: ${tanggalProduksi.toLocal()}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Product ID: $productId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              // Add more fields as needed
                              Text(
                                'BOM ID: $bomId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Status PRO: $statusPro',
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
    ).then((selectedPRO) {
      if (selectedPRO != null) {
        widget.onChanged(selectedPRO);

        // Update other fields based on selectedPRO if needed
        // ...
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perintah Produksi',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: widget.isEnabled ? _showProductionOrderDialog : null,
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
                    widget.selectedPRO ?? 'Select Production Order',
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
