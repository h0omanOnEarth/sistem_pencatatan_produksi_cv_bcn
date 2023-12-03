import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/delete_account_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/edit_passowrd_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/edit_profil_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/main_menu_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userEmail;
  String? userPosisi;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      getUserDetails(user.email ?? '');
    }
  }

  Future<void> getUserDetails(String email) async {
    final firestore = FirebaseFirestore.instance;
    final userRef =
        firestore.collection('employees').where('email', isEqualTo: email);
    final userSnapshot = await userRef.get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first;
      setState(() {
        userName = userData['nama'];
        userEmail = userData['email'];
        userPosisi = userData['posisi'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16)
                .add(const EdgeInsets.only(top: 30)),
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
                        const Row(
                          children: [
                            SizedBox(width: 8.0),
                            Text(
                              'My Profile',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to the notification screen
                            if (kIsWeb) {
                              if (userPosisi!.contains('Gudang')) {
                                Routemaster.of(context).push(
                                    '${NotifikasiScreen.routeName}?routeBack=${MainGudang.routeName}?selectedIndex=6');
                              } else if (userPosisi!.contains('Administrasi')) {
                                Routemaster.of(context).push(
                                    '${NotifikasiScreen.routeName}?routeBack=${MainAdministrasi.routeName}?selectedIndex=5');
                              } else {
                                Routemaster.of(context).push(
                                    '${NotifikasiScreen.routeName}?routeBack=${MainProduksi.routeName}?selectedIndex=4');
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotifikasiScreen(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color:
                                    Colors.grey, // Customize the border color
                                width: 1, // Customize the border width
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          email: userEmail ?? '',
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Set border radius
                      side: BorderSide(
                        color: Colors.grey[400]!, // Customize the border color
                        width: 1.0, // Set border width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: ClipOval(
                              // Gunakan ClipOval untuk membuat gambar menjadi lingkaran
                              child: Image.asset(
                                'images/profile.jpg', // Ganti dengan nama file gambar profil yang sesuai
                                width: MediaQuery.of(context).size.width * 0.05,
                                height:
                                    MediaQuery.of(context).size.width * 0.05,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // ignore: unnecessary_const
                                    const SizedBox(height: 8.0),
                                    Text(
                                      userEmail ?? '',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                          email: userEmail ?? '',
                                        )),
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditPasswordScreen(
                                email: userEmail ?? '',
                              )),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Set border radius
                      side: BorderSide(
                        color: Colors.grey[400]!, // Customize the border color
                        width: 1.0, // Set border width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.security),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Edit Password',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Change your password here',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DeleteAccountScreen(
                                email: userEmail ?? '',
                              )),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Set border radius
                      side: BorderSide(
                        color: Colors.grey[400]!, // Customize the border color
                        width: 1.0, // Set border width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.delete),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Delete your account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _auth.signOut().then((value) {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                      // );
                      if (kIsWeb) {
                        // ignore: use_build_context_synchronously
                        Routemaster.of(context).push(MainMenuScreen.routeName);
                      } else {
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainMenuScreen(),
                          ),
                        );
                      }
                    });

                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                    //   );

                    // Routemaster.of(context).push(MainMenuScreen.routeName);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Set border radius
                      side: BorderSide(
                        color: Colors.grey[400]!, // Customize the border color
                        width: 1.0, // Set border width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.logout),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Logout from your account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
