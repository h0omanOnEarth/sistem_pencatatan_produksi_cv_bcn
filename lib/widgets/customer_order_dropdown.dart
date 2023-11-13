import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/utils/format_date.dart';

ValueNotifier<String?> selectedCustomerOrderNotifier =
    ValueNotifier<String?>(null);

class CustomerOrderDropDownWidget extends StatefulWidget {
  final TextEditingController namaPelangganController;
  final TextEditingController alamatPengirimanController;
  final String? customerOrderId;
  final Function(String?) onChanged;
  final bool isEnabled;

  const CustomerOrderDropDownWidget({
    Key? key,
    required this.namaPelangganController,
    required this.alamatPengirimanController,
    required this.onChanged,
    this.customerOrderId,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  _CustomerOrderDropDownWidgetState createState() =>
      _CustomerOrderDropDownWidgetState();
}

class _CustomerOrderDropDownWidgetState
    extends State<CustomerOrderDropDownWidget> {
  late String? dropdownValue;
  String? selectedCustomerName;
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore
  final customerOrderService = CustomerOrderService();
  final customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    if (widget.customerOrderId != null) {
      selectedCustomerOrderNotifier.value = widget.customerOrderId;
    }
  }

  Future<String> _getCustomerName(String customerId) async {
    Map<String, dynamic>? customer =
        await customerService.getCustomerInfo(customerId);
    return customer?['nama'] ?? '';
  }

  Future<void> _showCustomerOrderDialog(BuildContext context) async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('customer_orders').get();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Customer Order'),
          content: SizedBox(
            width: double.maxFinite,
            child: Builder(
              builder: (BuildContext context) {
                List<QueryDocumentSnapshot> documents = snapshot.docs.toList();

                documents = documents.where((document) {
                  if (widget.isEnabled) {
                    return document['status'] == 1 &&
                        document['status_pesanan'] == "Dalam Proses";
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
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document = documents[index];
                    String orderId = document['id'];
                    String customerId = document['customer_id'];
                    String orderDate = DateFormatter.formatDate(
                        document['tanggal_pesan'].toDate());
                    String deliveryDate = DateFormatter.formatDate(
                        document['tanggal_kirim'].toDate());
                    String totalHarga = document['total_harga'].toString();
                    String totalProduk = document['total_produk'].toString();
                    String satuan = document['satuan'].toString();

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, orderId);

                        // Update selectedCustomerOrderNotifier
                        selectedCustomerOrderNotifier.value = orderId;
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
                                'Customer ID: $customerId',
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
                                'Total Harga: $totalHarga',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Total Produk: $totalProduk',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Satuan: $satuan',
                                style: const TextStyle(color: Colors.black),
                              ),
                              FutureBuilder(
                                future: _getCustomerName(customerId),
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
    ).then((selectedOrderId) async {
      if (selectedOrderId != null) {
        widget.onChanged(selectedOrderId);

        selectedCustomerOrderNotifier.value = selectedOrderId;

        // Fetch the selected customer order
        final selectedCustomerOrder = snapshot.docs.firstWhere(
          (document) => document['id'] == selectedOrderId,
        );

        // Update alamatPengirimanController based on the selected customer order
        widget.alamatPengirimanController.text =
            selectedCustomerOrder['alamat_pengiriman'] ?? '';

        // Update namaPelangganController based on the selected customer order's customer_id
        Map<String, dynamic>? customerName = await customerService
            .getCustomerInfo(selectedCustomerOrder['customer_id'] ?? '');
        widget.namaPelangganController.text = customerName?['nama'];
        if (selectedCustomerName != null) {
          widget.namaPelangganController.text = selectedCustomerName!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedCustomerOrderNotifier,
      builder: (context, selectedCustomerOrderId, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan Pelanggan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: widget.isEnabled
                  ? () => _showCustomerOrderDialog(context)
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
                        selectedCustomerOrderId ?? 'Select Customer Order',
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
}
