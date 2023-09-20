import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit_profile_screen';

  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 8.0),
                            Align(
                              alignment: Alignment.topLeft,
                              child: InkWell(
                                onTap: () {
                                  // Handle back button press
                                  Navigator.pop(context); // Navigates back
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.arrow_back, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24.0),
                            const Text(
                              'Sunting Profile',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0), // Add spacing between header and cards
                RoundedTextField(label: 'Nama', placeholder: 'Masukkan nama'),
                const SizedBox(height: 16.0),
                RoundedTextField(label: 'Nomor Telepon', placeholder: 'Masukkan nomor telepon'),
                const SizedBox(height: 16.0),
                RoundedTextField(label: 'Alamat', placeholder: 'Masukkan alamat'),
                const SizedBox(height: 16.0),
                RoundedTextField(label: 'Email', placeholder: 'Masukkan email'),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle save button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Simpan',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoundedTextField extends StatelessWidget {
  final String label;
  final String placeholder;

  RoundedTextField({required this.label, required this.placeholder});

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 8.0), // Add spacing between label and text field
        TextField(
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }
}
