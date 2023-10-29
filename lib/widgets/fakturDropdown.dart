// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/deliveryOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/suratJalanService.dart';

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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('invoices').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> invoiceItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          String invoiceId = document['id'];
          invoiceItems.add(
            DropdownMenuItem<String>(
              value: invoiceId,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoiceId,
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
              'Faktur',
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
                value: widget.selectedFaktur,
                items: invoiceItems,
                onChanged: widget.isEnabled
                    ? (newValue) async {
                        widget.onChanged(newValue);
                        _selectedDoc = snapshot.data!.docs.firstWhere(
                          (document) => document['id'] == newValue,
                        );

                        Map<String, dynamic>? shipment = await suratJalanService
                            .getSuratJalanInfo(_selectedDoc['shipment_id']);
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
                        widget.kodePelangganController?.text = customer?['id'];
                        widget.nomorPesananPelanggan?.text =
                            customerOrder?['id'];
                        widget.nomorSuratJalanController?.text =
                            shipment?['id'];
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
