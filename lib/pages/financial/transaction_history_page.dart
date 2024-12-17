import 'dart:io';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path;

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Transaction> transactionList = [];

  @override
  void initState() {
    super.initState();
    loadData();
    // Fetch the transaction list when the page is initialized
  }

  void loadData() async {
    var data = await Transaction.getTransactionList();
    transactionList = data.$1;
    transactionList.sort((a, b) => a.created_at.isAfter(b.created_at) ? 0 : 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HIGHTLIGHT_COLOR,
        appBar: BugAppBar('Transaction History', context),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // General Card for total amount (or other info)
            GeneralCard('Blah', () {}),
            SizedBox(height: 16),

            // List of transactions
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: transactionList.length,
              itemBuilder: (context, index) {
                Transaction transaction = transactionList[index];
                return TransactionCard(transaction:  transaction, loadData: loadData);
              },
            ),
          ],
        ));
  }

}
