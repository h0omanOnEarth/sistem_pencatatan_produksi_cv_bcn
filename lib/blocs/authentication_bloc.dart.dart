import 'package:bloc/bloc.dart';
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
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        yield LoginSuccess(user: userCredential.user!);
      } catch (e) {
        yield LoginFailure(error: e.toString()); // Menambahkan informasi kesalahan
      }
    } else if (event is LogoutButtonPressed) {
      await _auth.signOut();
      yield LoginInitial();
    }
  }
}
