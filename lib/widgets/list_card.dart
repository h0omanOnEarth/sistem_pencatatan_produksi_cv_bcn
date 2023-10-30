import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDeletePressed;
  final VoidCallback onTap;
  final String? status;
  final double? progressBarValue; // Tambahkan parameter progressBarValue

  const ListCard({
    Key? key, // Tambahkan key yang hilang
    required this.title,
    required this.description,
    required this.onDeletePressed,
    required this.onTap,
    this.status,
    this.progressBarValue, // Tambahkan parameter progressBarValue
  }) : super(key: key); // Tambahkan key ke dalam constructor

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
        onTap: onTap,
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
                      if (progressBarValue != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: LinearProgressIndicator(
                            value: progressBarValue,
                            minHeight: 20,
                            backgroundColor: Colors.grey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue),
                          ),
                        ),
                      if (progressBarValue != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              '${(progressBarValue! * 100).toStringAsFixed(0)}% Complete'),
                        ),
                    ],
                  ),
                ),
                if (status != "0" && status != "Selesai")
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
