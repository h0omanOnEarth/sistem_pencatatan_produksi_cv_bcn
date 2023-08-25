import 'package:flutter/material.dart';

class NotifikasiScreen extends StatefulWidget {
  static const routeName = '/notifikasi_screen';

  const NotifikasiScreen({super.key});
  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
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
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 8.0),
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
                            SizedBox(width: 24.0),
                            Text(
                              'Notification',
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
                SizedBox(height: 24.0), // Add spacing between header and cards
                // Create 6 cards
                buildCard('Card 1', 'This is a small description for Card 1'),
                buildCard('Card 2', 'This is a small description for Card 2'),
                buildCard('Card 3', 'This is a small description for Card 3'),
                buildCard('Card 4', 'This is a small description for Card 4'),
                buildCard('Card 5', 'This is a small description for Card 5'),
                buildCard('Card 6', 'This is a small description for Card 6'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard(String title, String description) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
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
            SizedBox(height: 4), // Add spacing between title and description
            Text(
              description,
              style: const TextStyle(
                color: Colors.grey, // Set text color to grey
                fontSize: 12, // Set a smaller font size
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}