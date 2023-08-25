import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final String placeholder;
  final bool multiline;
  final bool isEnabled;
  final bool isNumeric;
  final bool isEmail;
  final bool isPassword; // Tambahkan parameter untuk input teks password
  final TextEditingController? controller;

  const TextFieldWidget({
    required this.label,
    required this.placeholder,
    this.multiline = false,
    this.isEnabled = true,
    this.isNumeric = false,
    this.isEmail = false,
    this.isPassword = false, // Defaultnya false
    this.controller,
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
        TextField(
          controller: controller,
          maxLines: multiline ? 3 : 1,
          enabled: isEnabled,
          obscureText: isPassword, // Set obscured text based on isPassword
          keyboardType: isNumeric
              ? TextInputType.number
              : isEmail
                  ? TextInputType.emailAddress
                  : TextInputType.text,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: isEnabled ? Colors.white : Colors.grey[300],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            hintStyle: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }
}
