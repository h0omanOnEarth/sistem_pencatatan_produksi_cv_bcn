import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final String placeholder;
  final bool multiline;
  final bool isEnabled;
  final bool isNumeric;
  final bool isEmail;
  final bool isPassword;
  final bool isController;
  final bool isVisible; // Add isVisible parameter
  final TextEditingController? controller;
  final void Function(String)? onChanged; // Added onChanged callback

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.placeholder,
    this.multiline = false,
    this.isEnabled = true,
    this.isNumeric = false,
    this.isEmail = false,
    this.isPassword = false,
    this.isController = true,
    this.isVisible = true, // Initialize isVisible with true
    this.controller,
    this.onChanged, // Initialize onChanged callback
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      // Return an empty container if not visible
      return Container();
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
        TextField(
          controller: isController ? controller : null,
          maxLines: multiline ? 3 : 1,
          enabled: isEnabled,
          obscureText: isPassword,
          keyboardType: isNumeric
              ? TextInputType.number
              : isEmail
                  ? TextInputType.emailAddress
                  : TextInputType.text,
          onChanged: onChanged, // Set the onChanged callback
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
