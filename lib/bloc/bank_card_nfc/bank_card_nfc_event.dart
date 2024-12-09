part of 'bank_card_nfc_bloc.dart';

sealed class BankCardNfcEvent {
  const BankCardNfcEvent();


}

class BankCardDetectedEvent extends BankCardNfcEvent {
  final EmvCard card;

  BankCardDetectedEvent({required this.card});
  
}

class BankCardDisappearEvent extends BankCardNfcEvent{
  
}