import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProdukDropDown extends StatefulWidget {
  final TextEditingController namaProdukController;
  final TextEditingController? versionController;
  final TextEditingController? dimensiControler;
  final TextEditingController? beratController;
  final TextEditingController? ketebalanController;
  final TextEditingController? satuanController;
  final String? selectedKode;
  final bool isEnabled;
  final Function(String?) onChanged;

  ProdukDropDown({
    required this.namaProdukController,
    this.versionController,
    this.dimensiControler,
    this.beratController,
    this.ketebalanController,
    this.satuanController,
    this.selectedKode,
    required this.onChanged,
    this.isEnabled = true,
  }) : super();

  @override
  _ProdukDropDownState createState() => _ProdukDropDownState();
}

class _ProdukDropDownState extends State<ProdukDropDown> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<int> _generateNextVersion(String selectedKode) async {
    final bomsRef = firestore.collection('bill_of_materials');
    final QuerySnapshot snapshot =
        await bomsRef.where('product_id', isEqualTo: selectedKode).get();
    final List<int> existingVersions = [];

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      final versiBom = doc['versi_bom'] as int;
      existingVersions.add(versiBom);
    }

    int nextVersion = 1;

    if (existingVersions.isNotEmpty) {
      final latestVersion = existingVersions
          .reduce((value, element) => value > element ? value : element);
      nextVersion = latestVersion + 1;
    }

    return nextVersion;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nama Produk',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8.0),
        StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            List<DropdownMenuItem<String>> productItems = [];

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
              String productId = document['id'];
              String productName = document['nama'];
              productItems.add(
                DropdownMenuItem<String>(
                  value: productId,
                  child: Text(
                    productName,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: DropdownButtonFormField<String>(
                value: widget.selectedKode,
                items: productItems,
                onChanged: widget.isEnabled
                    ? (newValue) async {
                        final selectedProduk = snapshot.data!.docs.firstWhere(
                          (document) => document['id'] == newValue,
                        );
                        widget.namaProdukController.text =
                            selectedProduk['id'] ?? '';

                        widget.dimensiControler?.text =
                            selectedProduk['dimensi'].toString();
                        widget.beratController?.text =
                            selectedProduk['berat'].toString();
                        widget.ketebalanController?.text =
                            selectedProduk['ketebalan'].toString();
                        widget.satuanController?.text =
                            selectedProduk['satuan'].toString();

                        final nextVersion =
                            await _generateNextVersion(selectedProduk['id']);
                        widget.versionController?.text = nextVersion.toString();

                        // Panggil onChanged
                        widget.onChanged(newValue);
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
            );
          },
        ),
      ],
    );
  }
}
