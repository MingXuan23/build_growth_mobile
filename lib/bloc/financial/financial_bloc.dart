import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'financial_event.dart';
part 'financial_state.dart';

class FinancialBloc extends Bloc<FinancialEvent, FinancialState> {
  AuthRepo? repo;

  FinancialBloc(FinancialState initial, this.repo) : super(initial) {
    on<FinancialLoadData>(
      (event, emit) async {
        var totalAssets = await Asset.getTotalAsset();
        var totalDebts = await Debt.getTotalDebt();
        var data = await Transaction.getTransactionList();
        var transcationList = data.$1.where((x)=>x.transaction_type !=2).toList();
        var cashFlowList = data.$2;
        var totalCashFlow = await Asset.getTotalCashFlow();
        emit(FinancialDataLoaded(totalAssets: totalAssets, totalDebts: totalDebts,transactionList:transcationList, totalCashflow: totalCashFlow, cashflowTransactionList: cashFlowList));
      },
    );
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
