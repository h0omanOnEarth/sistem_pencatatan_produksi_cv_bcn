import 'package:flutter/material.dart';

class CircleFilterNotCalendarIconButton extends StatelessWidget {
  final Function onPressed;

  const CircleFilterNotCalendarIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: () {
          onPressed();
        },
      ),
    );
  }
}
