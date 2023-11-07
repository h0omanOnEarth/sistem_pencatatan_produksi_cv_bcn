import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

ValueNotifier<String?> selectedCustomerOrderNotifier =
    ValueNotifier<String?>(null);

class CustomerOrderDropDownWidget extends StatefulWidget {
  final TextEditingController namaPelangganController;
  final TextEditingController alamatPengirimanController;
  final String? customerOrderId;
  final Function(String?) onChanged;
  final bool isEnabled;

  CustomerOrderDropDownWidget({
    required this.namaPelangganController,
    required this.alamatPengirimanController,
    required this.onChanged,
    this.customerOrderId,
    this.isEnabled = true,
  }) : super();

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

  @override
  void initState() {
    super.initState();
    if (widget.customerOrderId != null) {
      selectedCustomerOrderNotifier.value = widget.customerOrderId;
    }
  }

  Future<void> fetchCustomerName(String customerId) async {
    final customerQuery = await firestore
        .collection('customers')
        .where('id', isEqualTo: customerId)
        .get();

    if (customerQuery.docs.isNotEmpty) {
      final customerDocument = customerQuery.docs.first;
      setState(() {
        selectedCustomerName = customerDocument['nama'] ?? '';
      });
    }
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
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('customer_orders').snapshots(),
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
                        document['status_pesanan'] == "Dalam Proses";
                  } else {
                    // Jika isEnabled false, tampilkan semua data
                    return true;
                  }
                }).toList();

                documents.sort((a, b) {
                  DateTime dateA = a['tanggal_pesan'].toDate();
                  DateTime dateB = b['tanggal_pesan'].toDate();
                  return dateB.compareTo(dateA);
                });

                List<DropdownMenuItem<String>> customerOrderItems = [];

                for (QueryDocumentSnapshot document in documents) {
                  String customerOrderId = document['id'];
                  customerOrderItems.add(
                    DropdownMenuItem<String>(
                      value: customerOrderId,
                      child: Text(
                        customerOrderId,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                }

                String? initialValue = selectedCustomerOrderId;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: initialValue,
                    items: customerOrderItems,
                    onChanged: widget.isEnabled
                        ? (newValue) async {
                            widget.onChanged(newValue);
                            selectedCustomerOrderNotifier.value = newValue;
                            final selectedCustomerOrder =
                                snapshot.data!.docs.firstWhere(
                              (document) => document['id'] == newValue,
                            );
                            widget.alamatPengirimanController.text =
                                selectedCustomerOrder['alamat_pengiriman'] ??
                                    '';

                            // Ambil nama pelanggan berdasarkan 'customer_id'
                            await fetchCustomerName(
                                selectedCustomerOrder['customer_id'] ?? '');
                            if (selectedCustomerName != null) {
                              widget.namaPelangganController.text =
                                  selectedCustomerName!;
                            }
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
