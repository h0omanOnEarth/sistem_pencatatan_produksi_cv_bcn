// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/deliveryOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/suratJalanService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/utils/format_date.dart';

class FakturDropdown extends StatefulWidget {
  final String? selectedFaktur;
  final Function(String?) onChanged;
  late final TextEditingController? namaPelangganController;
  late final TextEditingController? nomorPesananPelanggan;
  late final TextEditingController? kodePelangganController;
  late final TextEditingController? nomorSuratJalanController;
  late final TextEditingController? alamatController;
  final bool isEnabled;

  FakturDropdown({
    required this.selectedFaktur,
    required this.onChanged,
    this.namaPelangganController,
    this.nomorPesananPelanggan,
    this.kodePelangganController,
    this.nomorSuratJalanController,
    this.alamatController,
    this.isEnabled = true,
  });

  @override
  State<FakturDropdown> createState() => _FakturDropdownState();
}

class _FakturDropdownState extends State<FakturDropdown> {
  late QueryDocumentSnapshot _selectedDoc; // Menyimpan dokumen yang dipilih
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore
  final customerOrderService = CustomerOrderService();
  final customerService = CustomerService();
  final deliveryOrderService = DeliveryOrderService();
  final suratJalanService = SuratJalanService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Faktur',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: widget.isEnabled ? () => _showFakturDialog(context) : null,
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
                    widget.selectedFaktur ?? 'Select Faktur',
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

  Future<void> _showFakturDialog(BuildContext context) async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('invoices').get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Faktur'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents = documents.where((document) {
                  if (widget.isEnabled) {
                    return document['status'] == 1 &&
                        document['status_fk'] == "Selesai";
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
                    String fakturId = document['id'];
                    String shipmentId = document['shipment_id'];
                    DateTime tanggalPembuatan =
                        document['tanggal_pembuatan'].toDate();
                    String metodePembayaran =
                        document['metode_pembayaran'] ?? '';
                    String nomorRekening = document['nomor_rekening'] ?? '';
                    String total = document['total'].toString();
                    String statusPembayaran =
                        document['status_pembayaran'] ?? '';

                    return InkWell(
                      onTap: () async {
                        Navigator.pop(context, fakturId);

                        // Call the onChanged callback with the selected value
                        widget.onChanged(fakturId);

                        // Update other fields based on selectedFaktur if needed
                        if (widget.namaPelangganController != null) {
                          _selectedDoc = snapshot.docs.firstWhere(
                            (doc) => doc['id'] == fakturId,
                          );

                          Map<String, dynamic>? shipment =
                              await suratJalanService.getSuratJalanInfo(
                                  _selectedDoc['shipment_id']);
                          Map<String, dynamic>? deliveryOrder =
                              await deliveryOrderService.getDeliveryOrderInfo(
                                  shipment?['deliveryOrderId'] as String);
                          final customerOrderId =
                              deliveryOrder?['customerOrderId'] as String;
                          Map<String, dynamic>? customerOrder =
                              await customerOrderService
                                  .getCustomerOrderInfo(customerOrderId);
                          Map<String, dynamic>? customer = await customerService
                              .getCustomerInfo(customerOrder?['customer_id']);
                          widget.alamatController?.text =
                              shipment?['alamatPenerima'];
                          widget.namaPelangganController?.text =
                              customer?['nama'];
                          widget.kodePelangganController?.text =
                              customer?['id'];
                          widget.nomorPesananPelanggan?.text =
                              customerOrder?['id'];
                          widget.nomorSuratJalanController?.text =
                              shipment?['id'];
                        }
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $fakturId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Shipment ID: $shipmentId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Tanggal Pembuatan: ${DateFormatter.formatDate(tanggalPembuatan)}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Metode Pembayaran: $metodePembayaran',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Nomor Rekening: $nomorRekening',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Total: $total',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Status Pembayaran: $statusPembayaran',
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
    ).then((selectedFaktur) {
      if (selectedFaktur != null) {
        //widget.onChanged(selectedFaktur);

        // Update other fields based on selectedFaktur if needed
        // ...
      }
    });
  }

  Future<String> _getCustomerName(String customerOrderId) async {
    Map<String, dynamic>? customerOrder =
        await customerOrderService.getCustomerOrderInfo(customerOrderId);
    Map<String, dynamic>? customer =
        await customerService.getCustomerInfo(customerOrder?['customer_id']);
    return customer?['nama'] ?? '';
  }
}
