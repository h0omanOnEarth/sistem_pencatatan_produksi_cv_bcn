// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/deliveryOrderService.dart';

class SuratJalanDropDown extends StatefulWidget {
  final String? selectedSuratJalan;
  final Function(String?) onChanged;
  late final TextEditingController? namaPelangganController;
  late final TextEditingController? nomorPesananPelanggan;
  late final TextEditingController? kodePelangganController;
  late final TextEditingController? nomorDeliveryOrderController;
  final bool isEnabled;
  final String? mode;

  SuratJalanDropDown(
      {super.key,
      required this.selectedSuratJalan,
      required this.onChanged,
      this.namaPelangganController,
      this.nomorPesananPelanggan,
      this.kodePelangganController,
      this.nomorDeliveryOrderController,
      this.isEnabled = true,
      this.mode});

  @override
  State<SuratJalanDropDown> createState() => _SuratJalanDropDownState();
}

class _SuratJalanDropDownState extends State<SuratJalanDropDown> {
  late QueryDocumentSnapshot _selectedDoc; // Menyimpan dokumen yang dipilih
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore
  final customerOrderService = CustomerOrderService();
  final customerService = CustomerService();
  final deliveryOrderService = DeliveryOrderService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('shipments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Filter dan urutkan data secara lokal
        documents = documents.where((document) {
          if (widget.mode == "add") {
            // Jika isEnabled true, tambahkan pemeriksaan status pesanan pengiriman
            return document['status'] == 1 &&
                document['status_shp'] == "Dalam Proses";
          } else {
            // Jika isEnabled false, tampilkan semua data
            return true;
          }
        }).toList();

        documents.sort((a, b) {
          DateTime dateA = a['tanggal_pembuatan'].toDate();
          DateTime dateB = b['tanggal_pembuatan'].toDate();
          return dateB.compareTo(dateA);
        });

        List<DropdownMenuItem<String>> shipmentItems = [];

        for (QueryDocumentSnapshot document in documents) {
          String shipmentId = document['id'];
          shipmentItems.add(
            DropdownMenuItem<String>(
              value: shipmentId,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shipmentId,
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
              'Surat Jalan',
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
                value: widget.selectedSuratJalan,
                items: shipmentItems,
                onChanged: widget.isEnabled
                    ? (newValue) async {
                        widget.onChanged(newValue);
                        _selectedDoc = snapshot.data!.docs.firstWhere(
                          (document) => document['id'] == newValue,
                        );
                        Map<String, dynamic>? deliveryOrder =
                            await deliveryOrderService.getDeliveryOrderInfo(
                                _selectedDoc['delivery_order_id'] as String);
                        final customerOrderId =
                            deliveryOrder?['customerOrderId'] as String;
                        Map<String, dynamic>? customerOrder =
                            await customerOrderService
                                .getCustomerOrderInfo(customerOrderId);
                        Map<String, dynamic>? customer = await customerService
                            .getCustomerInfo(customerOrder?['customer_id']);
                        widget.namaPelangganController?.text =
                            customer?['nama'];
                        widget.kodePelangganController?.text = customer?['id'];
                        widget.nomorPesananPelanggan?.text =
                            customerOrder?['id'];
                        widget.nomorDeliveryOrderController?.text =
                            _selectedDoc['delivery_order_id'];
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
