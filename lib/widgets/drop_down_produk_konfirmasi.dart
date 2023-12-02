import 'package:flutter/material.dart';

class DropdownProdukDetailWidgetKonfirmasi extends StatelessWidget {
  final String label;
  final String selectedValue;
  final void Function(String) onChanged;
  final List<Map<String, dynamic>> products;
  final bool isEnabled; // Tambahkan properti isEnabled

  const DropdownProdukDetailWidgetKonfirmasi({
    required this.label,
    required this.selectedValue,
    required this.onChanged,
    required this.products,
    this.isEnabled =
        true, // Tambahkan properti isEnabled dengan nilai default true
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
                    style: TextStyle(
                      color: isEnabled
                          ? Colors.black
                          : Colors
                              .grey, // Gunakan isEnabled untuk mengatur warna teks
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: isEnabled
                ? (String? newValue) {
                    onChanged(newValue ?? '');
                  }
                : null, // Nonaktifkan onChanged jika isEnabled adalah false
          ),
        ),
      ],
    );
  }
}
