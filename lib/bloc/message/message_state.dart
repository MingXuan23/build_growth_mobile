part of 'message_bloc.dart';

sealed class MessageState{
  const MessageState();
  
 
}

final class MessageInitial extends MessageState {}

final class MessageSending extends MessageState {}

final class MessageSent extends MessageState {
  final String message;
  MessageSent(this.message);
}

final class MessageReply extends MessageState {
  final List<String> reply;
  final List<String> question;

  MessageReply(this.reply, this.question);
}

final class MessageSendError extends MessageState {
  final String error;
  MessageSendError(this.error);
}

final class MessageCompleted extends MessageState{}



// class ExampleState extends TemplateState {
//   final String error;

//   const ExampleState(this.error);

//   @override
//   List<Object> get props => [error];
// }

