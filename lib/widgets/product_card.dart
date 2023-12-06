import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final dynamic productCardData; // Gunakan dynamic
  final void Function() onDelete;
  final List<Widget> children;
  final bool isEnabled;

  const ProductCard({
    super.key,
    required this.productCardData,
    required this.onDelete,
    required this.children,
    this.isEnabled = true, // Tambahkan isEnabled dengan nilai default true
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: widget.children,
            ),
          ),
          if (widget.isEnabled) // Tambahkan pengecekan isEnabled
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onDelete,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Hapus',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
