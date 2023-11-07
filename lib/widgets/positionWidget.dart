import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PositionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data != null) {
              final user = snapshot.data!;
              final email = user.email;

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('employees')
                    .where('email', isEqualTo: email)
                    .get(),
                builder: (context, employeeSnapshot) {
                  if (employeeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (employeeSnapshot.hasError) {
                    return Text('Error: ${employeeSnapshot.error}');
                  } else if (employeeSnapshot.hasData &&
                      employeeSnapshot.data != null) {
                    final employeeDocs = employeeSnapshot.data!.docs;
                    if (employeeDocs.isNotEmpty) {
                      final employeeData = employeeDocs.isNotEmpty
                          ? employeeDocs.first.data() as Map<String, dynamic>
                          : null;
                      final posisi = employeeData?['posisi'];

                      return Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Posisi: ${posisi ?? "Tidak Ditemukan"}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      );
                    } else {
                      return const Text('Posisi tidak ditemukan');
                    }
                  } else {
                    return const Text('Data tidak ditemukan');
                  }
                },
              );
            } else {
              return const Text('Pengguna tidak ditemukan');
            }
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
