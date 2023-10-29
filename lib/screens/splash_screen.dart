import 'dart:async';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Timer untuk mengatur waktu tampilan SplashScreen
    Timer(const Duration(seconds: 3), () {
      // Navigasi ke halaman berikutnya setelah 3 detik
      Routemaster.of(context).push(MainMenuScreen.routeName);
    });

    // Membuat AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Membuat Tween untuk mengubah opacity dari 0.0 ke 1.0
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    // Memulai animasi
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double fontSize = 36.0;

    // Sesuaikan ukuran font berdasarkan lebar layar
    if (screenWidth < 600) {
      fontSize = 18.0;
    }

    return Scaffold(
      // Desain tampilan SplashScreen
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "CV. Berlian Cangkir Nusantara",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // const CircularProgressIndicator(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}
