import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final List<CustomCardContent> content;

  const CustomCard({
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[400]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var item in content)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  item.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                  strutStyle: StrutStyle.disabled,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomCardContent {
  final String text;
  final bool isBold;

  CustomCardContent({
    required this.text,
    this.isBold = false,
  });
}
