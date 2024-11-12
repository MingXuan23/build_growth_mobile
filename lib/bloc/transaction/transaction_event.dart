part of 'transaction_bloc.dart';

sealed class TransactionEvent {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class ShowPayDebtPage extends TransactionEvent {}

class ShowAssetIncrementPage extends TransactionEvent {}

class ShowAssetTransactionPage extends TransactionEvent {}


class ShowAssetReductionPage extends TransactionEvent {}

class ShowAssetTransferPage extends TransactionEvent {}

class CompleteTransactionAction extends TransactionEvent{}



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



