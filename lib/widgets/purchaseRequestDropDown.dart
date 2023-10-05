import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseRequestDropDown extends StatelessWidget {
  final String? selectedPurchaseRequest;
  final Function(String?) onChanged;
  final TextEditingController? jumlahPermintaanController;

  const PurchaseRequestDropDown({
    Key? key,
    required this.selectedPurchaseRequest,
    required this.onChanged,
    this.jumlahPermintaanController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('purchase_requests').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> purchaseRequestItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          String purchaseRequestId = document['id'];
          String jumlahPermintaan = document['jumlah'].toString(); // Ambil nilai 'jumlah' dan konversi ke String

          purchaseRequestItems.add(
            DropdownMenuItem<String>(
              value: purchaseRequestId,
              child: Text(
                purchaseRequestId,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );

          // Perbarui jumlahPermintaanController jika diberikan
          if (jumlahPermintaanController != null && selectedPurchaseRequest == purchaseRequestId) {
            Future.delayed(Duration.zero, () {
              jumlahPermintaanController?.text = jumlahPermintaan;
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
                value: selectedPurchaseRequest,
                items: purchaseRequestItems,
                onChanged: (newValue) {
                  onChanged(newValue);
                  // Perbarui jumlahPermintaanController saat item dipilih
                  if (jumlahPermintaanController != null) {
                    final selectedDoc = snapshot.data!.docs.firstWhere(
                      (doc) => doc['id'] == newValue,
                    );
                    jumlahPermintaanController?.text = selectedDoc['jumlah'].toString();
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
            ),
          ],
        );
      },
    );
  }
}
