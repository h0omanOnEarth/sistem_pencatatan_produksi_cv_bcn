import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

ValueNotifier<String?> selectedCustomerOrderNotifier = ValueNotifier<String?>(null);

class CustomerOrderDropDownWidget extends StatefulWidget {
  final TextEditingController namaPelangganController;
  final TextEditingController alamatPengirimanController;
  final String? customerOrderId;

  CustomerOrderDropDownWidget({
    required this.namaPelangganController,
    required this.alamatPengirimanController,
    this.customerOrderId,
  }) : super();

  @override
  _CustomerOrderDropDownWidgetState createState() => _CustomerOrderDropDownWidgetState();
}

class _CustomerOrderDropDownWidgetState extends State<CustomerOrderDropDownWidget> {
  late String? dropdownValue;
  String? selectedCustomerName;
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore

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

                List<DropdownMenuItem<String>> customerOrderItems = [];

                for (QueryDocumentSnapshot document in snapshot.data!.docs) {
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
                    onChanged: (newValue) async {
                      selectedCustomerOrderNotifier.value = newValue;
                      final selectedCustomerOrder = snapshot.data!.docs.firstWhere(
                        (document) => document['id'] == newValue,
                      );
                      widget.alamatPengirimanController.text =
                          selectedCustomerOrder['alamat_pengiriman'] ?? '';

                      // Ambil nama pelanggan berdasarkan 'customer_id'
                      await fetchCustomerName(selectedCustomerOrder['customer_id'] ?? '');
                      if (selectedCustomerName != null) {
                        widget.namaPelangganController.text = selectedCustomerName!;
                      }
                    },
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
