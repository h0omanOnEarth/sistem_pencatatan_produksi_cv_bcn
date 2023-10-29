import 'package:flutter/material.dart';

class DropdownDetailWidget extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selectedValue;
  final void Function(String) onChanged;
  final bool isEnabled;

  const DropdownDetailWidget({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    List<String> uniqueItems = items.toSet().toList(); // Remove duplicates

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
            value: selectedValue.isEmpty ? null : selectedValue,
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
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            }).toList(),
            onChanged: isEnabled
                ? (String? newValue) {
                    onChanged(newValue ??
                        ''); // Make sure to pass an empty string if newValue is null
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
