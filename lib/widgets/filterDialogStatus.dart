import 'package:flutter/material.dart';

class FilterDialogStatusWidget extends StatelessWidget {
  final String title;
  final Function(String) onFilterSelected;

  const FilterDialogStatusWidget({
    required this.title,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Filter Berdasarkan $title'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, '');
          },
          child: const Text('Semua'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, 'Aktif');
          },
          child: const Text('Aktif'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, 'Tidak Aktif');
          },
          child: const Text('Tidak Aktif'),
        ),
      ],
    );
  }
}
