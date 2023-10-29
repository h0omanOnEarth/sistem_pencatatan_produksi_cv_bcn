import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Buat ValueNotifier untuk mengelola selectedKode
ValueNotifier<String?> selectedKodeNotifier = ValueNotifier<String?>(null);

class PesananPembelianDropdown extends StatefulWidget {
  final TextEditingController tanggalPemesananController;
  final TextEditingController kodeBahanController;
  final TextEditingController namaBahanController;
  final TextEditingController namaSupplierController;
  final String? purchaseOrderId;
  final bool isEnabled;

  PesananPembelianDropdown({
    required this.tanggalPemesananController,
    required this.kodeBahanController,
    required this.namaBahanController,
    required this.namaSupplierController,
    this.purchaseOrderId,
    this.isEnabled = true,
  }) : super();

  @override
  _PesananPembelianDropdownState createState() =>
      _PesananPembelianDropdownState();
}

class _PesananPembelianDropdownState extends State<PesananPembelianDropdown> {
  late String? dropdownValue;

  @override
  void initState() {
    super.initState();
    if (widget.purchaseOrderId != null) {
      selectedKodeNotifier.value = widget.purchaseOrderId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedKodeNotifier,
      builder: (context, selectedPesanan, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan Pembelian',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('purchase_orders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> purchaseOrderItems = [];

                for (QueryDocumentSnapshot document in snapshot.data!.docs) {
                  String purchaseOrderId = document['id'];
                  purchaseOrderItems.add(
                    DropdownMenuItem<String>(
                      value: purchaseOrderId,
                      child: Text(
                        purchaseOrderId,
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
                    value: selectedPesanan,
                    items: purchaseOrderItems,
                    onChanged: widget.isEnabled
                        ? (newValue) {
                            selectedKodeNotifier.value = newValue;
                            final selectedPurchaseOrder =
                                snapshot.data!.docs.firstWhere(
                              (document) => document['id'] == newValue,
                            );
                            Timestamp timestamp =
                                selectedPurchaseOrder['tanggal_pesan']
                                    as Timestamp;
                            DateTime date = timestamp.toDate();
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(date);
                            widget.tanggalPemesananController.text =
                                formattedDate;
                            widget.kodeBahanController.text =
                                selectedPurchaseOrder['material_id'];
                            String materialId =
                                selectedPurchaseOrder['material_id'];
                            // Ambil data nama bahan dari koleksi 'materials' berdasarkan material_id
                            FirebaseFirestore.instance
                                .collection('materials')
                                .where('id', isEqualTo: materialId)
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              if (querySnapshot.docs.isNotEmpty) {
                                var materialDoc = querySnapshot.docs[0];
                                String namaBahan = materialDoc['nama'] ?? '';
                                widget.namaBahanController.text = namaBahan;
                              }
                            });

                            String supplierId =
                                selectedPurchaseOrder['supplier_id'];
                            // Ambil data nama supplier dari koleksi 'suppliers' berdasarkan supplier_id
                            FirebaseFirestore.instance
                                .collection('suppliers')
                                .where('id', isEqualTo: supplierId)
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              if (querySnapshot.docs.isNotEmpty) {
                                var supplierDoc = querySnapshot.docs[0];
                                String namaSupplier = supplierDoc['nama'] ?? '';
                                widget.namaSupplierController.text =
                                    namaSupplier;
                              }
                            });
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
