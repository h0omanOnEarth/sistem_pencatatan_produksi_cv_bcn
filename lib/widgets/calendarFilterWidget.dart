import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final String labelText;
  final Function onPressed;
  final String dateText;

  const DateSelector({super.key, 
    required this.labelText,
    required this.onPressed,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(labelText, style: const TextStyle(fontWeight: FontWeight.bold)),
        CircleFilterIconButton(
          onPressed: onPressed,
        ),
        Text(dateText),
      ],
    );
  }
}

class CircleFilterIconButton extends StatelessWidget {
  final Function onPressed;

  const CircleFilterIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: IconButton(
        icon: const Icon(Icons.calendar_today_rounded),
        onPressed: () {
          onPressed();
        },
      ),
    );
  }
}


