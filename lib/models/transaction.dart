
import 'package:build_growth_mobile/services/database_helper.dart';

class Transaction {
  final int? id;
  final double amount;
  final String desc;
  final int? asset_id;
  final int? debt_id;
  final String? user_code;
  final DateTime created_at;

  Transaction(this.user_code, { this.id, required this.amount, required this.desc, required this.asset_id, required this.debt_id, required this.created_at});

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
    return await DatabaseHelper().insertData('Transactions', transaction.toMap());
  }

  static Future<int> updateTransaction(Transaction transaction) async {
    return await DatabaseHelper().updateData('Transactions', transaction.toMap(), transaction.id!);
  }

  static Future<int> deleteTransaction(int id) async {
    return await DatabaseHelper().deleteData('Transactions', id);
  }
}
