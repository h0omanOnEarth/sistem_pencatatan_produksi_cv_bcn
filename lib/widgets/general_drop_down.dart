import 'package:flutter/material.dart';

class DropdownWidget extends StatelessWidget {
  final String label;
  final String selectedValue;
  final List<String> items;
  final void Function(String) onChanged;
  

  const DropdownWidget({
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
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
        SizedBox(height: 8.0),
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
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              onChanged(newValue ?? '');
            },
          ),
        ),
      ],
    );
  }
}
