part of 'auth_bloc.dart';

sealed class AuthState{
  const AuthState();
  
 
}

final class LoginInitial extends AuthState {}

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  
}

class LoginFailure extends AuthState {
  final String error;

  const LoginFailure(this.error);

  @override
  List<Object> get props => [error];
}
