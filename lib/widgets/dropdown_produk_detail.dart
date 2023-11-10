import 'package:flutter/material.dart';

class DropdownProdukDetailWidget extends StatelessWidget {
  final String label;
  final String selectedValue;
  final void Function(String) onChanged;
  final List<Map<String, dynamic>> products;
  final bool isEnabled; // Tambahkan properti isEnabled

  DropdownProdukDetailWidget({
    required this.label,
    required this.selectedValue,
    required this.onChanged,
    required this.products,
    this.isEnabled =
        true, // Tambahkan properti isEnabled dengan nilai default true
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = 16.0; // Ukuran font default

    // Periksa lebar layar
    if (MediaQuery.of(context).size.width <= 600) {
      fontSize = 14.0; // Ubah ukuran font untuk layar HP
    }

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
              String productName = product['nama'].toString();
              return DropdownMenuItem<String>(
                value: productId,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    productName,
                    style: TextStyle(
                      fontSize: fontSize,
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
