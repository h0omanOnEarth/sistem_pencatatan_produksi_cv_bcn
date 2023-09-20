import 'package:flutter/material.dart';

class FilterDialog extends StatelessWidget {
  final Function(String?) onFilterSelected;

  FilterDialog({required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Filter Berdasarkan Status Pengembalian Bahan'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            onFilterSelected('');
            Navigator.pop(context);
          },
          child: const Text('Semua'),
        ),
        SimpleDialogOption(
          onPressed: () {
            onFilterSelected('Dalam Proses');
            Navigator.pop(context);
          },
          child: const Text('Dalam Proses'),
        ),
        SimpleDialogOption(
          onPressed: () {
            onFilterSelected('Selesai');
            Navigator.pop(context);
          },
          child: const Text('Selesai'),
        ),
      ],
    );
  }
}
