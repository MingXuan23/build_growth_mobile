part of 'auth_bloc.dart';

sealed class AuthState {
  const AuthState();
}

final class LoginInitial extends AuthState {}

class AuthLoading extends AuthState {}

class LoginSuccess extends AuthState {}

class LoginFailure extends AuthState {
  final String error;

  const LoginFailure(this.error);

  @override
  List<Object> get props => [error];
}

class RegisterPendingCode extends AuthState {}

class RegisterPendingCodeWithMessgae extends AuthState {
  final String message;

  const RegisterPendingCodeWithMessgae(this.message);

  @override
  List<Object> get props => [message];
}

class RegisterSuccess extends AuthState {}

class RegisterFailure extends AuthState {
  final String error;

  const RegisterFailure(this.error);

  @override
  List<Object> get props => [error];
}

class RegisterContinued extends AuthState{}

class AuthRefreshCode extends AuthState{
  final bool? status;
  final int second;

  AuthRefreshCode({ this.status,  required this.second});
  
}
