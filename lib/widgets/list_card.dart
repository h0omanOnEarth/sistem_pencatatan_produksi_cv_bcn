import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDeletePressed; // Properti onDeletePressed
  final VoidCallback onTap; // Properti onTap
  final String? status;

  const ListCard({super.key, 
    required this.title,
    required this.description,
    required this.onDeletePressed,
    required this.onTap,
    this.status,
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
      child: InkWell(
        onTap: onTap, // Panggil onTap saat card ditekan
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
                          fontWeight: FontWeight.normal, // Ganti FontWeight ke bold
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[500]!,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
                if(status==null || status!="Selesai")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.red,
                    ),
                    child: IconButton(
                      iconSize: 21.0,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: onDeletePressed,
                    ),
                  ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
