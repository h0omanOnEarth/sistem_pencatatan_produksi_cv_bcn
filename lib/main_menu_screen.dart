import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/login_screen.dart';


class MainMenuScreen extends StatelessWidget {
  static const routeName = '/main_menu_screen';
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Menu Page',
      theme: ThemeData(
        primaryColor:
            Colors.white, // Ganti dengan kode hex warna yang diinginkan
      ),
      home: const LoginRegisterPage(),
      routes: {
        '/login_page_screen': (context) =>
            const LoginPageScreen(),
      },
    );
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
              Container(
                  margin: const EdgeInsets.all(10),
                  child: Image.asset('images/logo2.png')),
              Container(
                width: 350,
                height: 50,
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    // Tombol login ditekan
                    Navigator.pushNamed(context,
                        '/login_page_screen'); // Pindahkan ke halaman login
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
