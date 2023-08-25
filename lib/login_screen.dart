import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/main_menu_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/authentication_bloc.dart.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/produksi/main/main_produksi.dart'; // Pastikan import ini sesuai dengan lokasi AuthenticationBloc

class LoginPageScreen extends StatefulWidget {
  static const routeName = '/login_page_screen';
  const LoginPageScreen({super.key});

  @override
  State<LoginPageScreen> createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPageScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoginPage',
      theme: ThemeData(
        primaryColor:
            Colors.white, // Ganti dengan kode hex warna yang diinginkan
      ),
      home: LoginPage(),
      routes: {
        '/main_menu_screen': (context) =>
            const MainMenuScreen(), // Definisikan rute untuk halaman kedua
        '/main_admnistrasi': (context) => const MainAdministrasi(),
        '/main_gudang':(context)=> const MainGudang(),
        '/main_produksi':(context)=> const MainProduksi()    
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double desiredHeightPercentage =
        0.1; // Adjust the desired height percentage (e.g., 0.5 for 50%)

    return BlocProvider(
      create: (context) => AuthenticationBloc(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'images/background_white.jpg'), // Ganti dengan path/lokasi gambar Anda
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    primaryColor: const Color.fromRGBO(
                        59, 51, 51, 1), // Change the border color
                    hintColor: Colors.blueGrey, // Change the hint text color
                  ),
                  child: ListView(
                    children: [
                      SizedBox(
                          height: screenHeight *
                              0.02), // Added extra space to align the back button properly
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, MainMenuScreen.routeName);
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
                      SizedBox(
                        height: screenHeight * desiredHeightPercentage,
                      ),
                      const Text(
                        'Sign In',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color.fromRGBO(59, 51, 51, 1),
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       const SizedBox(height: 16.0),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color.fromRGBO(
                                59, 51, 51, 1), // Change the icon color
                          ),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(
                                  59, 51, 51, 1), // Change the border color
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(
                                  59, 51, 51, 1), // Change the border color
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(
                                  59, 51, 51, 1), // Change the border color
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 10.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color.fromRGBO(
                                59, 51, 51, 1), // Change the icon color
                          ),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(
                                  59, 51, 51, 1), // Change the border color
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(
                                  59, 51, 51, 1), // Change the border color
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(
                                  59, 51, 51, 1), // Change the border color
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 10.0,
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () async {
                            // try {
                            //   final email = _emailController.text;
                            //   final password = _passwordController.text;

                            //   // Dispatch SignInEvent to the AuthenticationBloc
                            //   BlocProvider.of<AuthenticationBloc>(context).add(
                            //     SignInEvent(email, password),
                            //   );
                            // } on Exception catch (e) {
                            //   final snackbar =
                            //       SnackBar(content: Text(e.toString()));
                            //   ScaffoldMessenger.of(context)
                            //       .showSnackBar(snackbar);
                            // } finally {}
                            
                            Navigator.pushNamed(context,
                              '/main_admnistrasi'); // Pindahkan ke halaman administrasi
                            //  Navigator.pushNamed(context,
                            //   '/main_gudang'); // Pindahkan ke halaman gudang
                              // Navigator.pushNamed(context,
                              // '/main_produksi'); // Pindahkan ke halaman produksi
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromRGBO(59, 51, 51, 1)),
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
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
            )
          ],
        ),
      ),
    );
  }
}