import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String message;

  SuccessDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sukses'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
