part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}


class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}


class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent{
  final String name;
  final String password;
  final String telno;
  final String address;
  final String state;
  final String email;

  const RegisterRequested({required this.name, required this.password, required this.telno, required this.address, required this.state, required this.email});
}


