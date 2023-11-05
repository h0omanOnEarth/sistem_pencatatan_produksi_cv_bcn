import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final bool isObscure; // Tambahkan isObscure di sini dengan default false

  const RoundedTextField({
    Key? key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.isObscure = false, // Tambahkan isObscure dengan default false
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
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          obscureText:
              isObscure, // Set isObscure untuk mengatur apakah harus diubah menjadi titik-titik atau tidak
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
