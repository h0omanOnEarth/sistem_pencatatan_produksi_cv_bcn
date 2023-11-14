import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final bool isEnabled;

  const DatePickerButton({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = selectedDate ?? DateTime.now();
    String dateText = DateFormat.yMMMMd().format(currentDate);

    Color textColor = selectedDate == null ? Colors.grey[500]! : Colors.black;

    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor =
        screenWidth > 600 ? 1.0 : 0.8; // Sesuaikan dengan kebutuhan Anda

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
          onPressed: isEnabled
              ? () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: currentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    onDateSelected(pickedDate);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                  fontSize:
                      14.0 * scaleFactor, // Sesuaikan dengan kebutuhan Anda
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
