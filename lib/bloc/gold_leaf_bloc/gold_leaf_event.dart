part of 'gold_leaf_bloc.dart';

sealed class GoldLeafEvent extends Equatable {
  const GoldLeafEvent();

  @override
  List<Object> get props => [];
}


class LoadGoldLeafEvent extends GoldLeafEvent{

}

class CompleteGoldLeafEvent extends GoldLeafEvent{

}

class ChatGoldLeafEvent extends GoldLeafEvent{

}

class ShareGoldLeafEvent extends GoldLeafEvent{
  
}



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



