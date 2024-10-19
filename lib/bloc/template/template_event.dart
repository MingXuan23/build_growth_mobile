part of 'template_bloc.dart';

sealed class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object> get props => [];
}

class ExampleEvent extends TemplateEvent {}

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



