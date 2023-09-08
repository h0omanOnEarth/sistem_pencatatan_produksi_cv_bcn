import 'package:flutter/material.dart';

class DropdownProdukDetailWidget extends StatelessWidget {
  final String label;
  final String selectedValue;
  final void Function(String) onChanged;
  final List<Map<String, dynamic>> products; // Tambahkan parameter ini

  DropdownProdukDetailWidget({
    required this.label,
    required this.selectedValue,
    required this.onChanged,
    required this.products, // Tambahkan ini
  });

  @override
  Widget build(BuildContext context) {
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
            value: selectedValue.isEmpty ? null : selectedValue,
            underline: Container(),
            items: products.map((product) {
              String productId = product['id'].toString();
              return DropdownMenuItem<String>(
                value: productId,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    productId,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              onChanged(newValue ?? ''); // Pastikan untuk memberikan string kosong jika newValue adalah null
            },
          ),
        ),
      ],
    );
  }
}
