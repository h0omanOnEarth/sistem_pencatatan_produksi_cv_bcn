import 'package:flutter/material.dart';

class DropdownWidget extends StatelessWidget {
  final String label;
  final String selectedValue;
  final List<String> items;
  final void Function(String) onChanged;
  final bool isEnabled; // Tambahkan isEnabled dengan nilai default true

  const DropdownWidget({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.isEnabled = true, // Nilai default isEnabled adalah true
  });

  @override
  Widget build(BuildContext context) {
    List<String> uniqueItems = items.toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedValue,
            underline: Container(),
            items: uniqueItems.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isEnabled
                          ? Colors.black
                          : Colors
                              .grey, // Atur warna teks sesuai dengan isEnabled
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: isEnabled
                ? (String? newValue) {
                    // Hanya panggil onChanged jika isEnabled adalah true
                    onChanged(newValue ?? '');
                  }
                : null, // Tambahkan null jika isEnabled adalah false
          ),
        ),
      ],
    );
  }
}
