import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/card.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'bank_card_nfc_event.dart';
part 'bank_card_nfc_state.dart';

class BankCardNfcBloc extends Bloc<BankCardNfcEvent, BankCardNfcState> {


  EmvCard? current_card;
  BankCardNfcBloc(BankCardNfcState initial) : super(initial) {
    on<BankCardDetectedEvent>(
      (event, emit) async {
        if(current_card == event.card){
          return;
        }
        current_card =event.card;
        emit(BankCardDetectedState(card: event.card));
      },
    );

    on<BankCardDisappearEvent>((event, emit) {
      current_card= null;
       emit(BankCardInitialState());
    },);
  }
}


//brief explanation

//user trigger a action and u should add the event to the bloc provider like this
/*BlocProvider.of<AuthBloc>(context).add(
        LoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      ); 
*/

//then u handle the event in the bloc class

//the state was emitted, the changes will listened by bloc listener in the pages

//after created a new bloc remember add it to the main.dart
