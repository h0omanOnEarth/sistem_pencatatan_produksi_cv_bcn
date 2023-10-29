import 'package:flutter/material.dart';

class PaginationButton extends StatelessWidget {
  final Function? onPressed;
  final String label;

  const PaginationButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed as void Function()?,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown,
      ),
      child: Text(label),
    );
  }
}
