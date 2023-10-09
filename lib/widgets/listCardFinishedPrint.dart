import 'package:flutter/material.dart';

class ListCardFinishedPrint extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDeletePressed;
  final VoidCallback onTap;
  final VoidCallback? onPrintPressed;
  final VoidCallback? onFinished;
  final String status;

  const ListCardFinishedPrint({
    Key? key,
    required this.title,
    required this.description,
    required this.onDeletePressed,
    required this.onTap,
    this.onPrintPressed,
    this.onFinished,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align buttons to the start and end
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
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end, // Push elements to the end
                children: [
                  if (status != "Selesai")
                    Container(
                      width: 35.0, // Sesuaikan dengan ukuran yang Anda inginkan
                      height: 35.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.green,
                      ),
                      child: IconButton(
                        iconSize: 21.0, // Sesuaikan dengan ukuran yang Anda inginkan
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                        onPressed: onFinished,
                      ),
                    ),
                  const SizedBox(height: 8.0,),
                  Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.black,
                    ),
                    child: IconButton(
                      iconSize: 21.0,
                      icon: const Icon(
                        Icons.print,
                        color: Colors.white,
                      ),
                      onPressed: onPrintPressed,
                    ),
                  ),
                  const SizedBox(height: 8.0,),
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
    );
  }
}
