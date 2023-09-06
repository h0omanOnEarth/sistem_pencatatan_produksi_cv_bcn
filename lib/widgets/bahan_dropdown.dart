import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BahanDropdown extends StatefulWidget {
  final TextEditingController namaBahanController;
  final String? selectedKode;

  BahanDropdown({
    required this.namaBahanController,
    this.selectedKode,
  });

  @override
  _BahanDropdownState createState() => _BahanDropdownState();
}

class _BahanDropdownState extends State<BahanDropdown> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('materials').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> materialItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          String materialId = document['id'];
          materialItems.add(
            DropdownMenuItem<String>(
              value: materialId,
              child: Text(
                materialId,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        }

        // Atur nilai awal dropdown sesuai dengan selectedKode
        String? initialValue = widget.selectedKode;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kode Bahan',
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
                value: initialValue, // Gunakan initialValue
                items: materialItems,
                onChanged: (newValue) {
                  setState(() {
                    initialValue = newValue;
                    final selectedMaterial = snapshot.data!.docs.firstWhere(
                      (document) => document['id'] == newValue,
                    );
                    widget.namaBahanController.text =
                        selectedMaterial['nama'] ?? '';
                  });
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
