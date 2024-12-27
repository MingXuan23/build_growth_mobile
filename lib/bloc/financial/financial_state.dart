part of 'financial_bloc.dart';

sealed class FinancialState{
  const FinancialState();
  
 
}

final class FinancialInitial extends FinancialState {}

final class FinancialDataLoaded extends FinancialState {
  final double totalAssets;
  final double totalDebts;
  final double totalCashflow;
  final List<Transaction> transactionList;
  final List<Transaction> cashflowTransactionList;
  final double totalExpense;
  final int unpaidDebt;


  FinancialDataLoaded( {required this.totalAssets, required this.totalDebts, required this.transactionList, required this.totalCashflow, required this.cashflowTransactionList, required this.totalExpense, required this.unpaidDebt});



}
