import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDeletePressed; // Properti onDeletePressed

  const ListCard({
    required this.title,
    required this.description,
    required this.onDeletePressed, // Tambahkan ke constructor
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
      ),
      child: SizedBox(
        width: screenWidth,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 8.0),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red, // Ubah warna ikon sesuai kebutuhan Anda
                ),
                onPressed: onDeletePressed, // Panggil onDeletePressed saat tombol ditekan
              ),
            ],
          ),
        ),
      ),
    );
  }
}
