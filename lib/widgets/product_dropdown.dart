import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Buat ValueNotifier khusus untuk ProdukDropDown
ValueNotifier<String?> selectedProdukNotifier = ValueNotifier<String?>(null);

class ProdukDropDown extends StatefulWidget {
  final TextEditingController namaProdukController;
  late final TextEditingController? versionController;
  late final TextEditingController? dimensiControler;
  late final TextEditingController? beratController;
  late final TextEditingController? ketebalanController;
  late final TextEditingController? satuanController;
  final String? productId; // Tambahkan parameter customerId
  final bool isEnabled;

  ProdukDropDown(
      {required this.namaProdukController,
      this.versionController,
      this.dimensiControler,
      this.beratController,
      this.ketebalanController,
      this.satuanController,
      this.productId,
      this.isEnabled = true})
      : super();

  @override
  _ProdukDropDownState createState() => _ProdukDropDownState();
}

class _ProdukDropDownState extends State<ProdukDropDown> {
  late String? dropdownValue;
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      selectedProdukNotifier.value = widget.productId;
    }
  }

  Future<int> _generateNextVersion(String productId) async {
    final bomsRef = firestore.collection('bill_of_materials');
    final QuerySnapshot snapshot =
        await bomsRef.where('product_id', isEqualTo: productId).get();
    final List<int> existingVersions = [];

    // Iterasi melalui dokumen yang sesuai dengan kriteria
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      final versiBom = doc['versi_bom'] as int;
      existingVersions.add(versiBom);
    }

    int nextVersion = 1;

    if (existingVersions.isNotEmpty) {
      // Temukan versi terbaru
      final latestVersion = existingVersions
          .reduce((value, element) => value > element ? value : element);
      nextVersion = latestVersion + 1;
    }

    return nextVersion;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedProdukNotifier, // Gunakan selectedBahanNotifier
      builder: (context, selectedProduk, _) {
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
              stream: firestore
                  .collection('products')
                  .where(
                    'status',
                    isEqualTo: widget.isEnabled
                        ? 1
                        : null, // Filter status hanya saat isEnabled true
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> productItems = [];

                for (QueryDocumentSnapshot document in snapshot.data!.docs) {
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

                // Atur nilai awal dropdown sesuai dengan selectedBahan
                String? initialValue = selectedProduk;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: initialValue,
                    items: productItems,
                    onChanged: widget.isEnabled
                        ? (newValue) async {
                            selectedProdukNotifier.value =
                                newValue; // Gunakan selectedBahanNotifier
                            final selectedProduk =
                                snapshot.data!.docs.firstWhere(
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

                            final nextVersion = await _generateNextVersion(
                                selectedProduk['id']);
                            widget.versionController?.text =
                                nextVersion.toString();
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
      },
    );
  }
}
