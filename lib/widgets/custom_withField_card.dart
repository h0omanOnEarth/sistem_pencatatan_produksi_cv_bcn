import 'package:flutter/material.dart';

class CustomWithTextFieldCard extends StatelessWidget {
  final List<CustomWithTextFieldCardContent> content;

  const CustomWithTextFieldCard({
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[400]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var item in content)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: item.isTextField
                    ? TextField(
                        controller: item.controller, // Gunakan controller yang diberikan
                        decoration: InputDecoration(
                          hintText: item.text,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8), // Set the desired corner radius here
                            borderSide: BorderSide(
                              color: Colors.grey[400]!, // Set the desired border color here
                            ),
                          ),
                          filled: true,
                          fillColor: item.isEnabled ? Colors.white : Colors.grey[300],
                          enabled: item.isEnabled,
                        ),
                      )
                    : (item.isRow
                        ? Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: item.leftController, // Gunakan controller kiri yang diberikan
                                  enabled: item.leftEnabled, // Menggunakan nilai leftEnabled
                                  decoration: InputDecoration(
                                    hintText: item.leftHintText,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[400]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: item.leftEnabled ? Colors.white : Colors.grey[300],
                                    enabled: item.leftEnabled,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: item.rightController, // Gunakan controller kanan yang diberikan
                                  enabled: item.rightEnabled, // Menggunakan nilai rightEnabled
                                  decoration: InputDecoration(
                                    hintText: item.rightHintText,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[400]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: item.rightEnabled ? Colors.white : Colors.grey[300],
                                    enabled: item.rightEnabled,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            item.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
                            ),
                            strutStyle: StrutStyle.disabled,
                          )),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomWithTextFieldCardContent {
  final String text;
  final bool isBold;
  final bool isTextField;
  final bool isRow;
  final String? leftHintText;
  final String? rightHintText;
  final bool leftEnabled; // Kontrol enable/disable TextField kiri
  final bool rightEnabled; // Kontrol enable/disable TextField kanan
  final bool isEnabled; // Kontrol enable/disable TextField

  final TextEditingController? controller; // Controller untuk text field
  final TextEditingController? leftController; // Controller untuk text field kiri
  final TextEditingController? rightController; // Controller untuk text field kanan

  CustomWithTextFieldCardContent({
    required this.text,
    this.isBold = false,
    this.isTextField = false,
    this.isRow = false,
    this.leftHintText,
    this.rightHintText,
    this.leftEnabled = true,
    this.rightEnabled = true,
    this.isEnabled = true,
    this.controller, // Tambahkan controller
    this.leftController, // Tambahkan controller untuk kiri
    this.rightController, // Tambahkan controller untuk kanan
  });
}
