import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/main_menu_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/roundedTextfieldWidget.dart';

class DeleteAccountScreen extends StatefulWidget {
  static const routeName = '/profile/delete';
  final String? email;

  const DeleteAccountScreen({Key? key, this.email}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _passwordController = TextEditingController();
  String _selectedReason = 'Kesalahan Internal';
  String _errorMessage = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double fontSize = 24.0;

    if (MediaQuery.of(context).size.width <= 600) {
      fontSize = 18.0;
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
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
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24.0),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Hapus Akun",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      "Apakah anda yakin ingin menghapus akun anda?. Jika anda sudah menghapus akun anda maka anda tidak akan bisa login kembali.",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButton<String>(
                      value: _selectedReason,
                      items: [
                        'Mengundurkan diri',
                        'Kesalahan Internal',
                        'Ingin Istirahat',
                        'Alasan Lain',
                      ].map((String reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _selectedReason = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                    RoundedTextField(
                      label: 'Password',
                      placeholder: 'Masukkan password',
                      controller: _passwordController,
                      isObscure: true,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () {
                        confirmDeletion();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Hapus Akun',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void confirmDeletion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Akun'),
          content: const Text('Apakah anda yakin?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                deleteAccount();
                Navigator.pop(context);
              },
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAccount() async {
    final String password = _passwordController.text;

    try {
      setState(() {
        isLoading = true;
      });

      final User? user = _auth.currentUser;
      final AuthCredential credential = EmailAuthProvider.credential(
        email: widget.email!,
        password: password,
      );

      // Reauthenticate user
      await user?.reauthenticateWithCredential(credential);

      // Update Firestore data
      await _firestore
          .collection('employees')
          .where('email', isEqualTo: widget.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({
            'status': 0, // Set status to 0 for deleted account
          });
        }
      });

      _showSuccessMessageAndNavigateBack();
    } on FirebaseAuthException {
      setState(() {
        _errorMessage = 'Password salah. Gagal menghapus akun.';
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(errorMessage: _errorMessage);
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat menghapus akun.';
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(errorMessage: _errorMessage);
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Akun berhasil dihapus.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
                // You can navigate to another screen or pop the route.
                _signOutAndNavigateToMainMenu();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
      // You can navigate to another screen or pop the route.
      _signOutAndNavigateToMainMenu();
    });
  }

  void _signOutAndNavigateToMainMenu() {
    _auth.signOut().then((value) {
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
  }
}
