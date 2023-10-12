import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final bool isEnabled; // Tambahkan parameter isEnabled

  const DatePickerButton({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.isEnabled = true, // Tambahkan default value true
  });

  @override
  Widget build(BuildContext context) {
    String dateText = selectedDate == null
        ? 'Pilih Tanggal'
        : DateFormat.yMMMMd().format(selectedDate!);

    Color textColor = selectedDate == null ? Colors.grey[500]! : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: isEnabled ? () async { // Periksa isEnabled
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (pickedDate != null && pickedDate != selectedDate) {
              onDateSelected(pickedDate);
            }
          } : null, // Nonaktifkan tombol jika isEnabled adalah false
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey[400]!),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8.0),
              Text(
                dateText,
                style: TextStyle(
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
