// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/deliveryOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/utils/format_date.dart';

class SuratJalanDropDown extends StatefulWidget {
  final String? selectedSuratJalan;
  final Function(String?) onChanged;
  late final TextEditingController? namaPelangganController;
  late final TextEditingController? nomorPesananPelanggan;
  late final TextEditingController? kodePelangganController;
  late final TextEditingController? nomorDeliveryOrderController;
  final bool isEnabled;
  final String? mode;

  SuratJalanDropDown({
    Key? key,
    required this.selectedSuratJalan,
    required this.onChanged,
    this.namaPelangganController,
    this.nomorPesananPelanggan,
    this.kodePelangganController,
    this.nomorDeliveryOrderController,
    this.isEnabled = true,
    this.mode,
  }) : super(key: key);

  @override
  State<SuratJalanDropDown> createState() => _SuratJalanDropDownState();
}

class _SuratJalanDropDownState extends State<SuratJalanDropDown> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore
  final customerOrderService = CustomerOrderService();
  final customerService = CustomerService();
  final deliveryOrderService = DeliveryOrderService();

  @override
  Widget build(BuildContext context) {
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
        GestureDetector(
          onTap: widget.isEnabled ? () => _showSuratJalanDialog(context) : null,
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
                    widget.selectedSuratJalan ?? 'Select Surat Jalan',
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

  Future<void> _showSuratJalanDialog(BuildContext context) async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('shipments').get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Surat Jalan'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents = documents.where((document) {
                  if (widget.mode == "add") {
                    return document['status'] == 1 &&
                        document['status_shp'] == "Dalam Proses";
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
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document = documents[index];
                    String shipmentId = document['id'];
                    String deliveryOrderId =
                        document['delivery_order_id'] as String;
                    String creationDate = DateFormatter.formatDate(
                        document['tanggal_pembuatan'].toDate());

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, shipmentId);
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $shipmentId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Delivery Order ID: $deliveryOrderId',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Creation Date: $creationDate',
                                style: const TextStyle(color: Colors.black),
                              ),
                              FutureBuilder(
                                future: _getCustomerOrderInfo(deliveryOrderId),
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
                                      'Customer Order ID: ${snapshot.data}',
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
    ).then((selectedSuratJalan) async {
      if (selectedSuratJalan != null) {
        widget.onChanged(selectedSuratJalan);

        // Find the selected document
        final selectedDoc = snapshot.docs.firstWhere(
          (document) => document['id'] == selectedSuratJalan,
        );

        // Update other fields based on selectedSuratJalan
        Map<String, dynamic>? deliveryOrder = await deliveryOrderService
            .getDeliveryOrderInfo(selectedDoc['delivery_order_id'] as String);
        final customerOrderId = deliveryOrder?['customerOrderId'] as String;
        Map<String, dynamic>? customerOrder =
            await customerOrderService.getCustomerOrderInfo(customerOrderId);
        Map<String, dynamic>? customer = await customerService
            .getCustomerInfo(customerOrder?['customer_id']);
        widget.namaPelangganController?.text = customer?['nama'];
        widget.kodePelangganController?.text = customer?['id'];
        widget.nomorPesananPelanggan?.text = customerOrder?['id'];
        widget.nomorDeliveryOrderController?.text =
            selectedDoc['delivery_order_id'];
      }
    });
  }

  Future<String> _getCustomerInfo(String customerOrderId) async {
    Map<String, dynamic>? customerOrder =
        await customerOrderService.getCustomerOrderInfo(customerOrderId);
    Map<String, dynamic>? customer =
        await customerService.getCustomerInfo(customerOrder?['customer_id']);
    return customer?['nama'] ?? '';
  }

  Future<String> _getCustomerOrderInfo(String deliveryOrderId) async {
    Map<String, dynamic>? deliveryOrder =
        await deliveryOrderService.getDeliveryOrderInfo(deliveryOrderId);
    final customerOrderId = deliveryOrder?['customerOrderId'] as String;
    return customerOrderId;
  }
}
