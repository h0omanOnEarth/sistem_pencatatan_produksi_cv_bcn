// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/bahanService.dart';

ValueNotifier<String?> selectedKodeNotifier = ValueNotifier<String?>(null);

class PesananPembelianDropdown extends StatefulWidget {
  final TextEditingController? tanggalPemesananController;
  final TextEditingController? kodeBahanController;
  final TextEditingController? namaBahanController;
  final TextEditingController? jumlahController;
  final TextEditingController? satuanController;
  final TextEditingController? namaSupplierController;
  final String? purchaseOrderId;
  final bool isEnabled;

  PesananPembelianDropdown({
    this.tanggalPemesananController,
    this.kodeBahanController,
    this.namaBahanController,
    this.jumlahController,
    this.satuanController,
    this.namaSupplierController,
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
      dropdownValue = widget.purchaseOrderId;
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
            GestureDetector(
              onTap: widget.isEnabled
                  ? () => _showPesananPembelianDialog(context)
                  : null,
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
                        selectedPesanan ?? 'Select Purchase Order',
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

  Future<void> _showPesananPembelianDialog(BuildContext context) async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('purchase_orders').get();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Pesanan Pembelian'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents = documents.where((document) {
                  if (widget.isEnabled) {
                    return document['status'] == 1 &&
                        document['status_pengiriman'] == "Selesai";
                  } else {
                    return true;
                  }
                }).toList();

                documents.sort((a, b) {
                  DateTime dateA = a['tanggal_pesan'].toDate();
                  DateTime dateB = b['tanggal_pesan'].toDate();
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document = documents[index];
                    String orderId = document['id'];
                    String purchaseRequestId = document['purchase_request_id'];
                    String orderDate = DateFormat('dd/MM/yyyy').format(
                      document['tanggal_pesan'].toDate(),
                    );
                    String deliveryDate = DateFormat('dd/MM/yyyy').format(
                      document['tanggal_kirim'].toDate(),
                    );
                    String materialId = document['material_id'];
                    String jumlah = document['jumlah'].toString();
                    String satuan = document['satuan'].toString();

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, orderId);

                        selectedKodeNotifier.value = orderId;

                        // Set dropdownValue untuk memastikan nilai terpilih ditampilkan di dropdown
                        setState(() {
                          dropdownValue = orderId;
                        });

                        // Mengisi widget.controllers
                        widget.tanggalPemesananController?.text = orderDate;
                        widget.kodeBahanController?.text = materialId;
                        widget.jumlahController?.text = jumlah;

                        // Memanggil layanan untuk mendapatkan nama material berdasarkan materialId
                        MaterialService().getMaterialInfo(materialId).then(
                          (namaMaterial) {
                            widget.namaBahanController?.text =
                                namaMaterial?['nama'];
                          },
                        );

                        // Ganti dengan kode yang sesuai
                        widget.namaSupplierController?.text =
                            document['supplier_id'];
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $orderId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Purchase Request ID: $purchaseRequestId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Order Date: $orderDate',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Delivery Date: $deliveryDate',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Material ID: $materialId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Jumlah: $jumlah',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Satuan: $satuan',
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
    ).then((selectedOrderId) {
      if (selectedOrderId != null) {
        selectedKodeNotifier.value = selectedOrderId;
      }
    });
  }
}
