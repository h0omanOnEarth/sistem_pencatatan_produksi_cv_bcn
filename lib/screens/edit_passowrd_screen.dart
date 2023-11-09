import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/roundedTextfieldWidget.dart';

class EditPasswordScreen extends StatefulWidget {
  static const routeName = '/profile/password';
  final String? email;

  const EditPasswordScreen({Key? key, this.email}) : super(key: key);

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  String _errorMessage = '';
  bool isLoading = false;

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Password berhasil diperbarui.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 24.0; // Ukuran font default

    // Periksa lebar layar
    if (MediaQuery.of(context).size.width <= 600) {
      fontSize = 18.0; // Ubah ukuran font untuk layar HP
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
                                "Sunting Password",
                                style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  RoundedTextField(
                    label: 'Password Sekarang',
                    placeholder: 'Masukkan Password saat ini',
                    controller: _currentPasswordController,
                    isObscure: true,
                  ),
                  const SizedBox(height: 16.0),
                  RoundedTextField(
                    label: 'Password Baru',
                    placeholder: 'Masukkan password baru',
                    controller: _newPasswordController,
                    isObscure: true,
                  ),
                  const SizedBox(height: 16.0),
                  RoundedTextField(
                    label: 'Konfirmasi Password Baru',
                    placeholder: 'Masukkan ulang password baru',
                    controller: _confirmNewPasswordController,
                    isObscure: true,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      updatePassword();
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
                        'Simpan',
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
      )),
    );
  }

  Future<void> updatePassword() async {
    final String currentPassword = _currentPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmNewPasswordController.text;

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Password baru dan konfirmasi tidak cocok.';
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(errorMessage: _errorMessage);
        },
      );

      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final User? user = _auth.currentUser;
      final AuthCredential credential = EmailAuthProvider.credential(
        email: widget.email!,
        password: currentPassword,
      );

      await user?.reauthenticateWithCredential(credential);
      await user?.updatePassword(newPassword);

      await _firestore
          .collection('employees')
          .where('email', isEqualTo: widget.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'password': newPassword});
        }
      });

      _showSuccessMessageAndNavigateBack();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(errorMessage: _errorMessage);
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memperbarui password.';
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
}
