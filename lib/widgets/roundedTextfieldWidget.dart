import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller; // Tambahkan controller di sini

  const RoundedTextField({
    Key? key,
    required this.label,
    required this.placeholder,
    this.controller, // Tambahkan controller di sini
  }) : super(key: key);

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
        const SizedBox(height: 8.0), // Add spacing between label and text field
        TextField(
          controller: controller, // Tambahkan controller di sini
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }
}
