part of 'message_bloc.dart';

sealed class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

class SendMessageEvent extends MessageEvent {
  final String message;
  SendMessageEvent(this.message);
}

class RestartMessageEvent extends MessageEvent {}

class LoadMessageModel extends MessageEvent {}

class CheckMessageEvent extends MessageEvent {}


// class LoginRequested extends TemplateEvent {
//   final String email;
//   final String password;

//   const LoginRequested({
//     required this.email,
//     required this.password,
//   });

//   @override
//   List<Object> get props => [email, password];
// }



