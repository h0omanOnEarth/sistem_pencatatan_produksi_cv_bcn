import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/login_screen.dart';

class MainMenuScreen extends StatelessWidget {
  static const routeName = '/menu';
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginRegisterPage();
  }
}

class LoginRegisterPage extends StatelessWidget {
  const LoginRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'images/background_white.jpg'), // Ganti dengan path/lokasi gambar Anda
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  double fontSize = 48;
                  double spacing = 8.0;

                  if (screenWidth < 600) {
                    fontSize = 28;
                    spacing = 4.0;
                  }

                  return Column(
                    children: [
                      Text(
                        "CV. Berlian Cangkir",
                        style: TextStyle(
                          fontFamily:
                              'Montserrat', // Sesuaikan dengan font yang digunakan
                          fontSize:
                              fontSize, // Sesuaikan dengan ukuran font yang diinginkan
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        "Nusantara",
                        style: TextStyle(
                          fontFamily:
                              'Montserrat', // Sesuaikan dengan font yang digunakan
                          fontSize:
                              fontSize, // Sesuaikan dengan ukuran font yang diinginkan
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32.0),
              Container(
                width: 350,
                height: 50,
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    // Tombol login ditekan
                    if (kIsWeb) {
                      Routemaster.of(context).push(LoginPageScreen.routeName);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPageScreen(),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromRGBO(59, 51, 51, 1)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            15), // Set your desired border radius here
                      ),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
