import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/services/database_helper.dart';

class Transaction {
  final int? id;
  final double amount;
  final String desc;
  final int? asset_id;
  final int? debt_id;
  final String? user_code;
  final DateTime created_at;

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
      this.debt});

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'desc': desc,
      'asset_id': asset_id,
      'debt_id': debt_id,
      'user_code': user_code,
      'created_at': created_at.toIso8601String()
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

  static Future<List<Transaction>> getTransactionList() async {
    var db = await DatabaseHelper().database;

    // Query the database for all transactions with status true (1)
    final List<Map<String, dynamic>> maps = await db.query(
      'Transactions',
    );

    // Use Future.wait to handle multiple async operations
    List<Transaction> transactions = [];

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
      ));
    }

    return transactions;
  }
}
