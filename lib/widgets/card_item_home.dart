import 'package:flutter/material.dart';

class CardItemHome extends StatelessWidget {
  final String title;
  final List<String> items;

  CardItemHome(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Ubah padding
      child: Card(
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                  fontSize: 16), // Ubah ukuran teks
                            ),
                          ),
                          const Divider(),
                        ],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
