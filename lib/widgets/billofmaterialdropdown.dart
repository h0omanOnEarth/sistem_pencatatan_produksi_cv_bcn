import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';

class BillOfMaterialDropDown extends StatelessWidget {
  final String? selectedBOM;
  final Function(String?) onChanged;
  final bool isEnabled;

  BillOfMaterialDropDown({
    required this.selectedBOM,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill of Material',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: isEnabled ? () => _showBOMDialog(context) : null,
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
                    selectedBOM ?? 'Select Bill of Material',
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

  Future<void> _showBOMDialog(BuildContext context) async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('bill_of_materials').get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Bill of Material'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents = documents.where((document) {
                  if (isEnabled) {
                    return document['status_bom'] == 1 &&
                        document['status'] == 1;
                  } else {
                    return true;
                  }
                }).toList();

                documents.sort((a, b) {
                  DateTime dateA = a['tanggal_pembuatan'].toDate();
                  DateTime dateB = b['tanggal_pembuatan'].toDate();
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document = documents[index];
                    String bomId = document['id'];
                    String productId = document['product_id'] ?? '';
                    String versiBom = document['versi_bom'].toString();

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, bomId);
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $bomId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Versi BOM: $versiBom',
                                style: const TextStyle(color: Colors.black),
                              ),
                              FutureBuilder<Map<String, dynamic>?>(
                                future:
                                    ProductService().getProductInfo(productId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text('Loading...');
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  if (snapshot.hasData) {
                                    return Text(
                                      'Nama Produk: ${snapshot.data?['nama'] ?? ''}',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    );
                                  }
                                  return Container();
                                },
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
    ).then((selectedBOM) {
      if (selectedBOM != null) {
        onChanged(selectedBOM);

        // Update other fields based on selectedBOM if needed
        // ...
      }
    });
  }
}
