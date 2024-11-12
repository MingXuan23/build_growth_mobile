part of 'transaction_bloc.dart';

sealed class TransactionState{
  const TransactionState();
  
 
}

final class TransactionInitial extends TransactionState {}

final class TransactionDebtPageShow extends TransactionState{}

final class AssetTransactionrPageShow extends TransactionState{}

final class AssetTransferPageShow extends TransactionState{}


final class TransactionCompleted extends TransactionState{}



// class ExampleState extends TemplateState {
//   final String error;

//   const ExampleState(this.error);

//   @override
//   List<Object> get props => [error];
// }

