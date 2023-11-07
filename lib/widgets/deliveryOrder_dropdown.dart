// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';

class DeliveryOrderDropDown extends StatefulWidget {
  final String? selecteDO;
  final Function(String?) onChanged;
  late final TextEditingController? namaPelangganController;
  late final TextEditingController? nomorPesananPelanggan;
  late final TextEditingController? kodePelangganController;
  late final TextEditingController? alamatController;
  final bool isEnabled;

  DeliveryOrderDropDown({
    required this.selecteDO,
    required this.onChanged,
    this.namaPelangganController,
    this.nomorPesananPelanggan,
    this.kodePelangganController,
    this.alamatController,
    this.isEnabled = true,
  });

  @override
  State<DeliveryOrderDropDown> createState() => _DeliveryOrderDropDownState();
}

class _DeliveryOrderDropDownState extends State<DeliveryOrderDropDown> {
  late QueryDocumentSnapshot _selectedDoc; // Menyimpan dokumen yang dipilih
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore
  final customerOrderService = CustomerOrderService();
  final customerService = CustomerService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('delivery_orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        // Ambil data dari snapshot
        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Filter dan urutkan data secara lokal
        documents = documents.where((document) {
          if (widget.isEnabled) {
            // Jika isEnabled true, tambahkan pemeriksaan status pesanan pengiriman
            return document['status'] == 1 &&
                document['status_pesanan_pengiriman'] == "Dalam Proses";
          } else {
            // Jika isEnabled false, tampilkan semua data
            return true;
          }
        }).toList();

        documents.sort((a, b) {
          DateTime dateA = a['tanggal_pesanan_pengiriman'].toDate();
          DateTime dateB = b['tanggal_pesanan_pengiriman'].toDate();
          return dateB.compareTo(dateA);
        });

        List<DropdownMenuItem<String>> doItems = [];

        for (QueryDocumentSnapshot document in documents) {
          String doID = document['id'];
          doItems.add(
            DropdownMenuItem<String>(
              value: doID,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doID,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perintah Pengiriman',
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
              child: DropdownButtonFormField<String>(
                value: widget.selecteDO,
                items: doItems,
                onChanged: widget.isEnabled
                    ? (newValue) async {
                        widget.onChanged(newValue);
                        _selectedDoc = documents.firstWhere(
                          (document) => document['id'] == newValue,
                        );

                        widget.alamatController?.text =
                            _selectedDoc['alamat_pengiriman'];

                        Map<String, dynamic>? customerOrder =
                            await customerOrderService.getCustomerOrderInfo(
                                _selectedDoc['customer_order_id']);
                        Map<String, dynamic>? customer = await customerService
                            .getCustomerInfo(customerOrder?['customer_id']);
                        widget.namaPelangganController?.text =
                            customer?['nama'];
                        widget.kodePelangganController?.text = customer?['id'];
                        widget.nomorPesananPelanggan?.text =
                            customerOrder?['id'];
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
            ),
          ],
        );
      },
    );
  }
}
