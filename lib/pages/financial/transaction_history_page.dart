import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/card.dart';
import 'package:flutter/material.dart';

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
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: HIGHTLIGHT_COLOR,
        appBar: BugAppBar('Transaction History',context),
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
                return transactionCard(transaction);
              },
            ),
          ],
        ));
  }

 Widget transactionCard(Transaction transaction) {
  return Card(
    elevation: 4,
    margin: EdgeInsets.only(bottom: ResStyle.spacing),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white, // Card background color
    shadowColor: Colors.black, // Shadow color
    child: ListTile(
      contentPadding: EdgeInsets.all(ResStyle.spacing),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between the title and the amount
        children: [
          // Left: Other info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (transaction.asset != null)
                Text(
                  'From: ${transaction.asset!.name}',
                  style: TextStyle(color: Colors.green), // Color for asset info
                ),
              if (transaction.debt != null)
                Text(
                  'For: ${transaction.debt!.name}',
                  style: TextStyle(color: Colors.green), // Color for debt info
                ),
              Text(
                'Note: ${transaction.desc}',
                style: TextStyle(color: Colors.black87), // Description color
              ),
              Text(
                'Date: ${transaction.created_at.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.grey), // Date color (light grey)
              ),
            ],
          ),
          // Right: Amount
          Text(
            FormatterHelper.toDoubleString(transaction.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: TITLE_COLOR, // Title text color for the amount
            ),
          ),
        ],
      ),
    ),
  );
}


}
