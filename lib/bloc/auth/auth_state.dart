part of 'auth_bloc.dart';

sealed class AuthState {
  const AuthState();
}

final class LoginInitial extends AuthState {

   final String? email;
   final String? message;

  const LoginInitial({this.email, this.message});

  @override
  List<Object?> get props => [email];
}

class AuthLoading extends AuthState {}
class CodeLoading extends AuthState {}


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

class RegisterReject extends AuthState {
  final String error;

  const RegisterReject(this.error);

  @override
  List<Object> get props => [error];
}

class RegisterContinued extends AuthState{}

class AuthRefreshCode extends AuthState{
  final bool? status;
  final int second;

  AuthRefreshCode({ this.status,  required this.second});
  
}

class AuthLogOut extends AuthState{}

class AuthForgetPasswordPerforming extends AuthState{}

class AuthForgetPasswordResult extends AuthState{
  final String message;

  AuthForgetPasswordResult({required this.message});

  
}

class AuthChangePasswordResult extends AuthState{
  final String message;
  final bool success;

  AuthChangePasswordResult({required this.message, required this.success});

  
}

class AuthUpdateProfileResult extends AuthState{
  final String message;
  final bool success;

  AuthUpdateProfileResult({required this.message, required this.success});

  
}


class UserBackUpRunning extends AuthState{}

class UserRestoreRunning extends AuthState{}

class UserBackUpEnded extends AuthState{}

class UserRestoreEnded extends AuthState{}

class UserTourGuiding extends AuthState{}

class UserTourGuideEnd extends AuthState{}


class UserPrivacyReload extends AuthState{}

