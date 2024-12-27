import 'dart:io';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Transaction> transactionList = [];
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  double totalInflow = 0;
  double totalOutflow = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var data = await Transaction.getTransactionList(month: selectedMonth, year: selectedYear);
    transactionList = data.$1;
    calculateTotals();
    setState(() {});
  }

  void calculateTotals() {
    totalInflow = 0;
    totalOutflow = 0;

    for (var transaction in transactionList) {
      if (transaction.amount != null) {
        if (transaction.amount! > 0) {
          totalInflow += transaction.amount!;
        } else {
          totalOutflow += transaction.amount!.abs();
        }
      }
    }
  }

  void _onMonthYearChanged(int month, int year) {
    setState(() {
      selectedMonth = month;
      selectedYear = year;
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HIGHTLIGHT_COLOR,
      appBar: BugAppBar('Transaction History', context),
      body: ListView(
        padding: EdgeInsets.all(ResStyle.spacing),
        children: [
          // General Card for inflow/outflow totals with month/year selection
          GeneralCard(
            totalInflow: totalInflow,
            totalOutflow: totalOutflow,
            selectedMonth: selectedMonth,
            selectedYear: selectedYear,
            onMonthYearChanged: _onMonthYearChanged,
          ),
          SizedBox(height: 16),

          // List of transactions
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: transactionList.length,
            itemBuilder: (context, index) {
              Transaction transaction = transactionList[index];
              return TransactionCard(transaction: transaction, loadData: loadData);
            },
          ),
        ],
      ),
    );
  }
}
