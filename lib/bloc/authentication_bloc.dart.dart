// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class AuthenticationEvent {}

class SignInEvent extends AuthenticationEvent {
  final String email;
  final String password;
  SignInEvent(this.email, this.password);
}

// States
abstract class AuthenticationState {}

class InitialState extends AuthenticationState {}

class AuthenticatedState extends AuthenticationState {}

class ErrorState extends AuthenticationState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class AuthenticationBloc
  extends Bloc<AuthenticationEvent, AuthenticationState> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthenticationBloc() : super(InitialState());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is SignInEvent) {
      try {
        // final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        //   email: event.email,
        //   password: event.password,
        // );

        // if (userCredential.user != null) {
        //   yield AuthenticatedState();
        // } else {
        //   yield ErrorState("Authentication failed.");
        // }
      } catch (e) {
        yield ErrorState("Authentication failed.");
      }
    }
  }
}
