import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final List<String> content;

  const CustomCard({
    required this.title,
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
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            for (var item in content)
              Text(
                item,
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
