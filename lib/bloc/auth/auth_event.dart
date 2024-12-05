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



class CheckRegisterEmail extends AuthEvent{
  final String email;

  const CheckRegisterEmail({required this.email});
}

class SendVerificationCode extends AuthEvent{
  final String code;
  final String email;

  const SendVerificationCode({required this.code, required this.email});

}

class ResendVerificationCode extends AuthEvent{
  final String email;

  ResendVerificationCode({required this.email});

}

class AutoLoginRequest extends AuthEvent{
  
}

class AuthForgetPassword extends AuthEvent{
  final String email;

  AuthForgetPassword({required this.email});

  
}

class ChangePasswordRequest extends AuthEvent{
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({required this.oldPassword, required this.newPassword});

  
}

class AuthServiceNotAvailable extends AuthEvent{
  final String? cause;

  AuthServiceNotAvailable({required this.cause});
  
}

class  UpdateProfileRequest extends AuthEvent{
  final String name;
  final String state;
  final String address;
  final String telno;

  UpdateProfileRequest({required this.name, required this.state, required this.address, required this.telno});

}

