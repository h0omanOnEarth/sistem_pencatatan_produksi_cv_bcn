import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Event
abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  LoginButtonPressed({required this.email, required this.password});
}

class LogoutButtonPressed extends LoginEvent {}

// State
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginSuccess extends LoginState {
   final User user;

  LoginSuccess({required this.user});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      try {
        final email = event.email;
        final password = event.password;

        if (email.isNotEmpty && password.isNotEmpty) {
          final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('loginValidation');
          final HttpsCallableResult<dynamic> result =
              await callable.call(<String, dynamic>{
            'email': email,
            'password': password,
          });

          if (result.data['success'] == true) {
            final userCredential = await _auth.signInWithEmailAndPassword(
              email: event.email,
              password: event.password,
            );
             yield LoginSuccess(user: userCredential.user!);
          } else {
            yield LoginFailure(error: result.data['message']);
          }
        } else {
          yield LoginFailure(error: 'Harap isi kolom email dan password.');
        }
      } catch (error) {
        yield LoginFailure(error: 'Terjadi kesalahan: $error');
      }
    } else if (event is LogoutButtonPressed) {
    }
  }
}
