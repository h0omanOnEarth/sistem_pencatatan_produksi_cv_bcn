import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MachineDropdown extends StatelessWidget {
  final String? selectedMachine;
  final Function(String?) onChanged;
  final String title; // Tambahkan parameter judul teks

  MachineDropdown({required this.selectedMachine, required this.onChanged,required this.title});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('machines').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> machineItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          String machineName = document['nama'] ?? '';
          String machineId = document['id'];
          machineItems.add(
            DropdownMenuItem<String>(
              value: machineId,
              child: Text(
                '$machineId - $machineName',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title',
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
                value: selectedMachine,
                items: machineItems,
                onChanged: (newValue) {
                  onChanged(newValue);
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
