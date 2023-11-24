import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MachineDropdown extends StatefulWidget {
  final String? selectedMachine;
  final TextEditingController? namaMesinController;
  final Function(String?) onChanged;
  final String title;
  final bool isEnabled;
  final String? mode;

  const MachineDropdown(
      {super.key,
      required this.selectedMachine,
      required this.onChanged,
      required this.title,
      this.namaMesinController,
      this.isEnabled = true,
      this.mode});

  @override
  State<MachineDropdown> createState() => _MachineDropdownState();
}

class _MachineDropdownState extends State<MachineDropdown> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('machines')
          .where('tipe', isEqualTo: widget.title)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> machineItems = [];

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Filter dan urutkan data secara lokal
        documents = documents.where((document) {
          if (widget.isEnabled && widget.mode == "add") {
            // Jika isEnabled true, tambahkan pemeriksaan status
            return document['status'] == 1;
          } else {
            // Jika isEnabled false, tampilkan semua data
            return true;
          }
        }).toList();

        for (QueryDocumentSnapshot document in documents) {
          String machineName = document['nama'] ?? '';
          String machineId = document['id'];
          if (document['status'] == 1 || widget.selectedMachine == machineId) {
            machineItems.add(
              DropdownMenuItem<String>(
                value: machineId,
                child: Text(
                  machineName,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            );
          }
          if (widget.selectedMachine == machineId &&
              widget.namaMesinController != null) {
            Future.delayed(Duration.zero, () {
              widget.namaMesinController?.text = machineId;
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != 'Penggiling')
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            if (widget.title == 'Penggiling')
              Text(
                'Mesin',
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
                value: widget.selectedMachine,
                items: machineItems,
                onChanged: widget.isEnabled
                    ? (newValue) {
                        widget.onChanged(newValue);
                        if (widget.namaMesinController != null) {
                          final selectedMachineName = machineItems
                              .firstWhere(
                                (item) => item.value == newValue,
                                orElse: () => const DropdownMenuItem<String>(
                                    value: '', child: Text('')),
                              )
                              .child as Text;
                          widget.namaMesinController?.text =
                              selectedMachineName.data!;
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
            ),
          ],
        );
      },
    );
  }
}
