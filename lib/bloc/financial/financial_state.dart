part of 'financial_bloc.dart';

sealed class FinancialState{
  const FinancialState();
  
 
}

final class FinancialInitial extends FinancialState {}

final class FinancialDataLoaded extends FinancialState {
  final double totalAssets;
  final double totalDebts;

  FinancialDataLoaded({required this.totalAssets, required this.totalDebts});



}
