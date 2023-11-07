import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseRequestDropDown extends StatefulWidget {
  final String? selectedPurchaseRequest;
  final Function(String?) onChanged;
  final TextEditingController? jumlahPermintaanController;
  final TextEditingController? satuanPermintaanController;
  final bool isEnabled;

  const PurchaseRequestDropDown({
    Key? key,
    required this.selectedPurchaseRequest,
    required this.onChanged,
    this.jumlahPermintaanController,
    this.satuanPermintaanController,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<PurchaseRequestDropDown> createState() =>
      _PurchaseRequestDropDownState();
}

class _PurchaseRequestDropDownState extends State<PurchaseRequestDropDown> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('purchase_requests')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Filter dan urutkan data secara lokal
        documents = documents.where((document) {
          if (widget.isEnabled) {
            // Jika isEnabled true, tambahkan pemeriksaan status pesanan pengiriman
            return document['status'] == 1 &&
                document['status_prq'] == "Dalam Proses";
          } else {
            // Jika isEnabled false, tampilkan semua data
            return true;
          }
        }).toList();

        documents.sort((a, b) {
          DateTime dateA = a['tanggal_permintaan'].toDate();
          DateTime dateB = b['tanggal_permintaan'].toDate();
          return dateB.compareTo(dateA);
        });

        List<DropdownMenuItem<String>> purchaseRequestItems = [];

        for (QueryDocumentSnapshot document in documents) {
          String purchaseRequestId = document['id'];
          String jumlahPermintaan = document['jumlah'].toString();
          String satuanPermintaan = document['satuan'].toString();

          purchaseRequestItems.add(
            DropdownMenuItem<String>(
              value: purchaseRequestId,
              child: Text(
                purchaseRequestId,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );

          if (widget.jumlahPermintaanController != null &&
              widget.selectedPurchaseRequest == purchaseRequestId) {
            Future.delayed(Duration.zero, () {
              widget.jumlahPermintaanController?.text = jumlahPermintaan;
              widget.satuanPermintaanController?.text = satuanPermintaan;
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permintaan Pembelian',
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
                value: widget.selectedPurchaseRequest,
                items: purchaseRequestItems,
                onChanged: widget.isEnabled
                    ? (newValue) => widget.onChanged(newValue)
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
