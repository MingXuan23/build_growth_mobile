import 'dart:ui';

import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/services/database_helper.dart';

class Transaction {
  final int? id;
  final double amount;
  String desc;
  final int? asset_id;
  final int? debt_id;
  final String? user_code;
  final DateTime created_at;
  int transaction_type;
  String? image;
  //1 is normal
  //2 is asset transfer

  Asset? asset;
  Debt? debt;

  static final table = 'Transactions';
  Transaction(this.user_code,
      {this.id,
      required this.amount,
      required this.desc,
      required this.asset_id,
      required this.debt_id,
      required this.created_at,
      this.asset,
      this.debt,
      this.transaction_type =1,
      this.image});

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'desc': desc,
      'asset_id': asset_id,
      'debt_id': debt_id,
      'user_code': UserToken.user_code,
      'created_at': created_at.toIso8601String(),
      'transaction_type': transaction_type,
      'image':image
    };
  }

  static Future<int> insertTransaction(Transaction transaction) async {
    return await DatabaseHelper()
        .insertData('Transactions', transaction.toMap());
  }

  static Future<int> updateTransaction(Transaction transaction) async {
    return await DatabaseHelper()
        .updateData('Transactions', transaction.toMap(), transaction.id!);
  }

  static Future<int> deleteTransaction(int id) async {
    return await DatabaseHelper().deleteData('Transactions', id);
  }

  static Future<(List<Transaction>, List<Transaction>)> getTransactionList() async {
    var db = await DatabaseHelper().database;

    // Query the database for all transactions with status true (1)
    final List<Map<String, dynamic>> maps = await db.query('Transactions',
        where: 'user_code = "${UserToken.user_code}"');

    // Use Future.wait to handle multiple async operations
    List<Transaction> transactions = [];
    List<Transaction> cashFlowtransactions = [];

    for (var map in maps) {
      int? assetId = map['asset_id'];
      int? debtId = map['debt_id'];

      // Fetch asset and debt asynchronously
      Asset? asset = await Asset.getAssetById(assetId ?? -1);
      Debt? debt = await Debt.getDebtById(debtId ?? -1);

      // Create a new Transaction and add it to the list
      transactions.add(Transaction(
        map['user_code'],
        id: map['id'],
        amount: map['amount'],
        desc: map['desc'],
        asset_id: assetId,
        debt_id: debtId,
        created_at: DateTime.parse(map['created_at']),
        asset: asset,
        debt: debt,
        transaction_type: map['transaction_type']??1,
        image: map['image']
      ));

      if (asset?.type == "Cash" ||
          asset?.type == "Bank Card" ||
          asset?.type == "Other Asset") {
        cashFlowtransactions.add(Transaction(
          map['user_code'],
          id: map['id'],
          amount: map['amount'],
          desc: map['desc'],
          asset_id: map['asset_id'], // Assuming `assetId` comes from `map`
          debt_id: map['debt_id'], // Assuming `debtId` comes from `map`
          created_at: DateTime.parse(map['created_at']),
          asset: map['asset'], // Assuming `asset` comes from `map`
          debt: map['debt'], // Assuming `debt` comes from `map`
          transaction_type: map['transaction_type']??1,
           image: map['image']
        ));
      }
    }

    return (transactions, cashFlowtransactions);
  }

  //  static Future<List<Transaction>> getCashFlowTransactionList() async {
  //   var db = await DatabaseHelper().database;

  //   // Query the database for all transactions with status true (1)
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'Transactions',
  //     where: 'user_code = ${UserToken.user_code}'
  //   );

  //   // Use Future.wait to handle multiple async operations
  //   List<Transaction> transactions = [];

  //   for (var map in maps) {
  //     int? assetId = map['asset_id'];
  //     int? debtId = map['debt_id'];

  //     // Fetch asset and debt asynchronously
  //     Asset? asset = await Asset.getAssetById(assetId ?? -1);
  //     Debt? debt = await Debt.getDebtById(debtId ?? -1);

  //     // Create a new Transaction and add it to the list
  //     transactions.add(Transaction(
  //       map['user_code'],
  //       id: map['id'],
  //       amount: map['amount'],
  //       desc: map['desc'],
  //       asset_id: assetId,
  //       debt_id: debtId,
  //       created_at: DateTime.parse(map['created_at']),
  //       asset: asset,
  //       debt: debt,
  //     ));
  //   }

  //   return transactions;
  // }

  Future<String> promptFromTransaction() async {
    var prompt = '';

    var total_asset = await Asset.getTotalAsset();
    var total_debt = await Debt.getTotalDebt();

    var cash_flow_percent = amount * 100 / (total_asset - total_debt);

    if (amount < 0) {
      prompt = 'I spent RM ${amount.abs().toStringAsFixed(2)}.';
    } else {
      prompt = 'I earned RM ${amount.abs().toStringAsFixed(2)}';
    }

    if (asset != null) {
      prompt +=
          'My ${asset!.name} (${asset!.type}) was changed to ${asset!.value} after transaction. It increase ${cash_flow_percent}% of my cash flow';
    }
    if (debt != null) {
      prompt +=
          'This transction is for ${debt!.name} (${debt!.type}). It decrease ${cash_flow_percent}% of my cash flow ';
    }

    if (cash_flow_percent <= 2) {
      prompt += amount > 0
          ? 'Please provide simple positive feedback using the Rich Dad mindset.'
          : 'Please give neutral advice like a caring mom and call me "Dear."';
    } else if (cash_flow_percent <= 5) {
      prompt += amount > 0
          ? 'Please provide positive feedback using the Rich Dad mindset.'
          : 'Please give constructive advice like a thoughtful mom and call me "Dear."';
    } else if (cash_flow_percent <= 10) {
      prompt += amount > 0
          ? 'Please provide uplifting feedback using the Rich Dad mindset.'
          : 'Please give constructive advice like a thoughtful mom and call me "Dear."';
    } else if (cash_flow_percent <= 30) {
      prompt += amount > 0
          ? 'Please provide encouraging suggestions using the Rich Dad mindset.'
          : 'Please give stern advice like a firm mom and call me "Dear."';
    } else if (cash_flow_percent <= 50) {
      prompt += amount > 0
          ? 'Please provide inspirational suggestions using the Rich Dad mindset.'
          : 'Please give a warning like a concerned mom and call me "Dear."';
    } else {
      prompt += amount > 0
          ? 'Please provide highly motivational suggestions using the Rich Dad mindset.'
          : 'Please give an immediate warning like an anxious mom and call me "Dear."';
    }

    return prompt;
  }
}
