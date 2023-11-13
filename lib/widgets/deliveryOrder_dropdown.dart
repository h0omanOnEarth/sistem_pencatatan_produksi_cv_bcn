import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/utils/format_date.dart';

class DeliveryOrderDropDown extends StatefulWidget {
  final String? selectedDO;
  final Function(String?) onChanged;
  late final TextEditingController? namaPelangganController;
  late final TextEditingController? nomorPesananPelanggan;
  late final TextEditingController? kodePelangganController;
  late final TextEditingController? alamatController;
  final bool isEnabled;

  DeliveryOrderDropDown({
    required this.selectedDO,
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
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final customerOrderService = CustomerOrderService();
  final customerService = CustomerService();

  @override
  Widget build(BuildContext context) {
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
        GestureDetector(
          onTap: widget.isEnabled ? () => _showDODialog(context) : null,
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
                    widget.selectedDO ?? 'Select Perintah Pengiriman',
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

  Future<void> _showDODialog(BuildContext context) async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('delivery_orders').get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Perintah Pengiriman'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents = documents.where((document) {
                  if (widget.isEnabled) {
                    return document['status'] == 1 &&
                        document['status_pesanan_pengiriman'] == "Dalam Proses";
                  } else {
                    return true;
                  }
                }).toList();

                documents.sort((a, b) {
                  DateTime dateA = a['tanggal_pesanan_pengiriman'].toDate();
                  DateTime dateB = b['tanggal_pesanan_pengiriman'].toDate();
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document = documents[index];
                    String doID = document['id'];
                    String customerOrderID =
                        document['customer_order_id'] ?? '';
                    String metodePengiriman =
                        document['metode_pengiriman'] ?? '';
                    String namaEkspedisi = document['nama_ekspedisi'] ?? '';

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, doID);
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $doID',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Customer Order ID: $customerOrderID',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Tanggal Perintah Pengiriman: ${DateFormatter.formatDate(document['tanggal_pesanan_pengiriman'].toDate())}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Metode Pengiriman: $metodePengiriman',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Nama Ekspedisi: $namaEkspedisi',
                                style: const TextStyle(color: Colors.black),
                              ),
                              FutureBuilder(
                                future: _getCustomerName(customerOrderID),
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
                                      'Nama Customer: ${snapshot.data}',
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
    ).then((selectedDO) async {
      if (selectedDO != null) {
        widget.onChanged(selectedDO);

        final selectedDoc = snapshot.docs.firstWhere(
          (document) => document['id'] == selectedDO,
        );

        widget.alamatController?.text = selectedDoc['alamat_pengiriman'] ?? '';

        final customerOrder = await customerOrderService
            .getCustomerOrderInfo(selectedDoc['customer_order_id']);
        final customer = await customerService
            .getCustomerInfo(customerOrder?['customer_id']);

        if (customer != null) {
          widget.namaPelangganController?.text = customer['nama'];
          widget.kodePelangganController?.text = customer['id'];
        }

        if (customerOrder != null) {
          widget.nomorPesananPelanggan?.text = customerOrder['id'];
        }
      }
    });
  }

  Future<String> _getCustomerName(String customerOrderID) async {
    Map<String, dynamic>? customerOrder =
        await customerOrderService.getCustomerOrderInfo(customerOrderID);
    Map<String, dynamic>? customer =
        await customerService.getCustomerInfo(customerOrder?['customer_id']);
    return customer?['nama'] ?? '';
  }
}
