part of 'bank_card_nfc_bloc.dart';

sealed class BankCardNfcState{
  const BankCardNfcState();
  
 
}

final class BankCardInitialState extends BankCardNfcState {}

final class BankCardDetectedState extends BankCardNfcState {
  final EmvCard card;

  BankCardDetectedState({required this.card});
  
}


