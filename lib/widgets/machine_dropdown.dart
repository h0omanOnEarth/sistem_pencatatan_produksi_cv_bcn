import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MachineDropdown extends StatelessWidget {
  final String? selectedMachine;
  final TextEditingController? namaMesinController;
  final Function(String?) onChanged;
  final String title;
  final bool isEnabled;

  const MachineDropdown({
    super.key,
    required this.selectedMachine,
    required this.onChanged,
    required this.title,
    this.namaMesinController,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('machines')
          .where('tipe', isEqualTo: title)
          .where(
            'status',
            isEqualTo:
                isEnabled ? 1 : null, // Filter status hanya saat isEnabled true
          )
          .snapshots(),
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
                machineName,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
          if (selectedMachine == machineId && namaMesinController != null) {
            Future.delayed(Duration.zero, () {
              namaMesinController?.text = machineId;
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != 'Penggiling')
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            if (title == 'Penggiling')
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
                value: selectedMachine,
                items: machineItems,
                onChanged: isEnabled
                    ? (newValue) {
                        onChanged(newValue);
                        if (namaMesinController != null) {
                          final selectedMachineName = machineItems
                              .firstWhere(
                                (item) => item.value == newValue,
                                orElse: () => const DropdownMenuItem<String>(
                                    value: '', child: Text('')),
                              )
                              .child as Text;
                          namaMesinController?.text = selectedMachineName.data!;
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
