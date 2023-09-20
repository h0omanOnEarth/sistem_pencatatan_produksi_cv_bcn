import 'package:flutter/material.dart';

class FilterDialog extends StatelessWidget {
  final Function(String?) onFilterSelected;
  final String title;

  FilterDialog({required this.onFilterSelected, required this.title});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title), // Gunakan nilai title yang diberikan
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
