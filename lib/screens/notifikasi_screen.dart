import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotifikasiScreen extends StatefulWidget {
  static const routeName = '/notifikasi_screen';

  const NotifikasiScreen({Key? key}) : super(key: key);

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getEmployeeIdByEmail(String email) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot document = querySnapshot.docs.first;
      return document.id; // Mengembalikan employee_id
    } else {
      return null; // Tidak ditemukan employee dengan email yang sesuai
    }
  }

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
                                  Navigator.pop(context);
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
                SizedBox(height: 24.0),
                FutureBuilder<User?>(
                  future: _auth.authStateChanges().first,
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    final user = userSnapshot.data;

                    if (user == null) {
                      return Text('User not logged in');
                    }

                    final userEmailAddress = user.email;

                    return FutureBuilder<String?>(
                      future: getEmployeeIdByEmail(userEmailAddress!),
                      builder: (context, employeeIdSnapshot) {
                        if (employeeIdSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        final employeeId = employeeIdSnapshot.data;

                        if (employeeId == null) {
                          return Text('Employee not found for email: $userEmailAddress');
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('notifications')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            final notifications = snapshot.data?.docs ?? [];

                            // Filter notifikasi berdasarkan employee_id
                            final userNotifications = notifications.where((notification) {
                              final detailNotifications = notification.reference.collection('detail_notifications');
                              return detailNotifications.where((detail) {
                                final notificationEmployeeId = detail['employee_id'];
                                return notificationEmployeeId == employeeId;
                              }).isNotEmpty;
                            }).toList();

                            return Column(
                              children: userNotifications.map((notification) {
                                final pesan = notification['pesan'];
                                final status = notification['status'];
                                return buildCard(pesan, 'Status: $status');
                              }).toList(),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
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
            SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}