import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/authentication_bloc.dart.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/main_menu_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/utils/notify_awesome.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';

class LoginPageScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginPageScreen({Key? key}) : super(key: key);

  @override
  State<LoginPageScreen> createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPageScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    double screenHeight = MediaQuery.of(context).size.height;
    double desiredHeightPercentage = 0.1;
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          final email = emailController.text;

          // Mencocokkan email pengguna dengan Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('employees')
              .where('email', isEqualTo: email)
              .get()
              .then((querySnapshot) => querySnapshot.docs.firstOrNull);

          if (userDoc != null) {
            final posisi = userDoc.get('posisi');
            if (posisi == 'Administrasi') {
              // ignore: use_build_context_synchronously
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const MainAdministrasi(),
              //   ),
              // );
              // ignore: use_build_context_synchronously
              Routemaster.of(context).push(MainAdministrasi.routeName);
            } else if (posisi == 'Gudang') {
              // ignore: use_build_context_synchronously
              Routemaster.of(context).push(MainGudang.routeName);
            } else if (posisi == 'Produksi') {
              // ignore: use_build_context_synchronously
              Routemaster.of(context).push(MainProduksi.routeName);
            }
          }
        } else if (state is LoginFailure) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(errorMessage: state.error);
            },
          );
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background_white.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  primaryColor: const Color.fromRGBO(59, 51, 51, 1),
                  hintColor: Colors.blueGrey,
                ),
                child: ListView(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () {
                          // Navigator.pop(context);
                          Routemaster.of(context)
                              .push(MainMenuScreen.routeName);
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
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color.fromRGBO(59, 51, 51, 1),
                        ),
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(59, 51, 51, 1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(59, 51, 51, 1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(59, 51, 51, 1),
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
                      controller: passwordController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color.fromRGBO(59, 51, 51, 1),
                        ),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(59, 51, 51, 1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(59, 51, 51, 1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(59, 51, 51, 1),
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
                          // //cloud functions
                          // final email = emailController.text;
                          // final password = passwordController.text;
                          // loginBloc.add(LoginButtonPressed(email: email, password: password));

                          // final email = _emailController.text;
                          // final password = _passwordController.text;

                          // if (email.isNotEmpty && password.isNotEmpty) {
                          //     final email = _emailController.text;
                          //     final password = _passwordController.text;

                          //     loginBloc.add(LoginButtonPressed(email: email, password: password));
                          // } else {
                          //   final snackbar = SnackBar(content: Text('Harap isi kolom email dan password.'));
                          //   ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          // }

                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const MainProduksi(),
                          //   ),
                          // );
                          print("Mengirim notifikasi...");
                          Notify.instantNotify().then((notificationCreated) {
                            print("Notifikasi dikirim: $notificationCreated");
                          }).catchError((error) {
                            print(
                                "Terjadi kesalahan saat mengirim notifikasi: $error");
                          });

                          Routemaster.of(context)
                              .push(MainAdministrasi.routeName);

                          try {
                            final HttpsCallable callable =
                                FirebaseFunctions.instanceFor(
                                        region: "asia-southeast2")
                                    .httpsCallable('sendEmailNotif');
                            final HttpsCallableResult<dynamic> result =
                                await callable.call(<String, dynamic>{
                              'dest': 'clarissagracia.cg@gmail.com',
                              'subject': 'Login Baru',
                              'html': 'Login baru ke aplikasi'
                            });

                            if (result.data['success'] == true) {
                              print("Sent");
                            } else {
                              print(result.data['message']);
                            }
                          } catch (e) {
                            print(e.toString());
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromRGBO(59, 51, 51, 1)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state is LoginLoading) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state is LoginLoading) {
                return AbsorbPointer(
                  absorbing: true,
                  child: Container(),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
