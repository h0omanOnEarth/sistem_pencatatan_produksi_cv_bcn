import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:routemaster/routemaster.dart';

class NotifikasiScreen extends StatefulWidget {
  static const routeName = '/notifikasi';
  final String? routeBack;

  const NotifikasiScreen({Key? key, this.routeBack}) : super(key: key);

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                                if (kIsWeb) {
                                  Routemaster.of(context)
                                      .push(widget.routeBack!);
                                } else {
                                  Navigator.pop(context, null);
                                }
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
                                  child: Icon(Icons.arrow_back,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24.0),
                          const Text(
                            'Notifications',
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
              const SizedBox(height: 24.0),
              FutureBuilder<User?>(
                future: _auth.authStateChanges().first,
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    );
                  }

                  final user = userSnapshot.data;

                  if (user == null) {
                    return const Text('User not logged in');
                  }

                  final userEmailAddress = user.email;
                  return FutureBuilder<String?>(
                    future: fetchPositionEmployee(userEmailAddress!),
                    builder: (context, positionSnapshot) {
                      if (positionSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        );
                      }

                      userPosition = positionSnapshot.data;

                      if (userPosition == null) {
                        return Text(
                            'Employee not found for email: $userEmailAddress');
                      }

                      if (userPosition == 'Kepala Produksi') {
                        userPosition = 'Produksi';
                      }

                      return StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('notifications')
                            .where('posisi', isEqualTo: userPosition)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final notifications = snapshot.data?.docs ?? [];

                          // Sort notifications based on 'created_at' in descending order
                          notifications.sort((a, b) {
                            final aDate = a['created_at'];
                            final bDate = b['created_at'];

                            if (aDate is Timestamp && bDate is Timestamp) {
                              return bDate.compareTo(aDate);
                            } else if (aDate is String && bDate is String) {
                              return DateTime.parse(bDate)
                                  .compareTo(DateTime.parse(aDate));
                            }

                            return 0;
                          });

                          return Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final pesan = notifications[index]['pesan'];
                                final createdAt =
                                    notifications[index]['created_at'];

                                DateTime formattedDate;

                                if (createdAt is Timestamp) {
                                  // If 'created_at' is a Timestamp, use it directly
                                  formattedDate = createdAt.toDate();
                                } else if (createdAt is String) {
                                  // If 'created_at' is a String, convert it to DateTime
                                  formattedDate = DateTime.parse(createdAt);
                                } else {
                                  // Handle other cases or set a default value
                                  formattedDate = DateTime.now();
                                }

                                final formattedDateString =
                                    formatDate(formattedDate);

                                return buildCard(
                                    pesan, 'Tanggal: $formattedDateString');
                              },
                            ),
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
    );
  }

  String formatDate(DateTime date) {
    final day = date.day.toString();
    final month = getMonthName(date.month);
    final year = date.year.toString();
    return '$day $month $year';
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }

  Future<String?> fetchPositionEmployee(String email) async {
    try {
      final QuerySnapshot employeeSnapshot = await _firestore
          .collection('employees')
          .where('email', isEqualTo: email)
          .get();

      if (employeeSnapshot.docs.isNotEmpty) {
        final employeeData = employeeSnapshot.docs.first.data();
        if (employeeData != null && employeeData is Map<String, dynamic>) {
          return employeeData['posisi'];
        }
      }
      return null;
    } catch (error) {
      print('Error fetching employee position: $error');
      return null;
    }
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
            const SizedBox(
                height: 4), // Add spacing between title and description
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
