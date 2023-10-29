import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Buat ValueNotifier khusus untuk PelangganDropdownWidget
ValueNotifier<String?> selectedPelangganNotifier = ValueNotifier<String?>(null);

class PelangganDropdownWidget extends StatefulWidget {
  final TextEditingController namaPelangganController;
  final String? customerId; // Tambahkan parameter customerId
  final bool isEnabled;

  PelangganDropdownWidget({
    required this.namaPelangganController,
    this.customerId, // Jadikan customerId sebagai parameter opsional
    this.isEnabled = true,
  }) : super();

  @override
  _PelangganDropdownWidgetState createState() =>
      _PelangganDropdownWidgetState();
}

class _PelangganDropdownWidgetState extends State<PelangganDropdownWidget> {
  late String? dropdownValue;

  @override
  void initState() {
    super.initState();
    // Inisialisasi selectedPelangganNotifier dengan customerId jika ada
    if (widget.customerId != null) {
      selectedPelangganNotifier.value = widget.customerId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedPelangganNotifier, //
      builder: (context, selectedPelanggan, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kode Pelanggan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> customerItems = [];

                for (QueryDocumentSnapshot document in snapshot.data!.docs) {
                  String customerId = document['id'];
                  customerItems.add(
                    DropdownMenuItem<String>(
                      value: customerId,
                      child: Text(
                        customerId,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                }

                // Atur nilai awal dropdown sesuai dengan selectedBahan
                String? initialValue = selectedPelanggan;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: initialValue,
                    items: customerItems,
                    onChanged: widget.isEnabled
                        ? (newValue) {
                            selectedPelangganNotifier.value =
                                newValue; // Gunakan selectedBahanNotifier
                            final selectedPelanggan =
                                snapshot.data!.docs.firstWhere(
                              (document) => document['id'] == newValue,
                            );
                            widget.namaPelangganController.text =
                                selectedPelanggan['nama'] ?? '';
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
