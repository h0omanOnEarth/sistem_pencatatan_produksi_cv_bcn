import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Events
abstract class AuthenticationEvent {}

class SignInEvent extends AuthenticationEvent {
  final String email;
  final String password;
  SignInEvent({required this.email, required this.password});
}

class SignOutEvent extends AuthenticationEvent {}

// States
abstract class AuthenticationState {}

class InitialAuthenticationState extends AuthenticationState {}

class AuthenticatedState extends AuthenticationState {
  final User user;
  AuthenticatedState({required this.user});
}

class UnauthenticatedState extends AuthenticationState {}

// BLoC
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthenticationBloc() : super(InitialAuthenticationState());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is SignInEvent) {
      yield* _mapSignInEventToState(event);
    } else if (event is SignOutEvent) {
      yield* _mapSignOutEventToState();
    }
  }

  Stream<AuthenticationState> _mapSignInEventToState(
      SignInEvent event) async* {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        yield AuthenticatedState(user: userCredential.user!);
      } else {
        yield UnauthenticatedState();
      }
    } catch (e) {
      yield UnauthenticatedState();
    }
  }

  Stream<AuthenticationState> _mapSignOutEventToState() async* {
    await _auth.signOut();
    yield UnauthenticatedState();
  }
}
