import 'dart:async';

import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/services/database_helper.dart';

class Debt {
  static const String table = 'Debt';
  final int? id;
  String name;
  String type; // Removed total_amount as it's not in the database schema
  double monthly_payment;
  double alarming_limit = -1;
  int remaining_month;
  int total_month;
  bool
      status; // Changed from bool to int to match the database structure (0 or 1)
  String? desc; // Make desc nullable if it can be null
  final String? user_code;
  DateTime? last_payment_date; // Added last_payment as a nullable DateTime

  double total_expense = 0;
  double month_total_expense = 0;

  Debt(
    this.user_code, {
    this.id,
    required this.name,
    required this.type,
    required this.monthly_payment,
    required this.remaining_month,
    required this.total_month,
    required this.status, // Assuming status is represented as an integer (0 or 1)
    this.desc,
    this.alarming_limit = -1,
    this.last_payment_date, // Added last_payment to constructor
  }) {
    if (type == 'Expenses') {
      getTotalTransaction();
      getMonthlyTotal();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'monthly_payment': monthly_payment,
      'remaining_month': remaining_month,
      'total_month': total_month,
      'status':
          status ? 1 : 0, // No conversion needed since it's already an int
      'desc': desc,
      'user_code': UserToken.user_code,
      'alarming_limit': alarming_limit,
      'last_payment_date': last_payment_date
          ?.toIso8601String(), // Convert DateTime to ISO string for storage
    };
  }

  void getTotalTransaction() async {
    // Get the database instance
    var db = await DatabaseHelper().database;

    // Use raw SQL query to calculate the sum of the amount column
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
    SELECT SUM(amount) AS total
    FROM Transactions
    WHERE user_code = ? AND debt_id = ?
    ''',
      [UserToken.user_code, id], // Use parameterized query for safety
    );

    // Extract the sum from the query result
    double totalAmount = -(result.first['total'] ?? 0.0);

    total_expense = totalAmount;
  }

  Future<void> getMonthlyTotal() async {
    // Get the database instance
    var db = await DatabaseHelper().database;

    // Get the current date to filter transactions for the current month
    final DateTime now = DateTime.now();
    final String currentMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}'; // Format as YYYY-MM

    // Use raw SQL query to calculate the sum for the current month
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
    SELECT SUM(amount) AS total
    FROM Transactions
    WHERE strftime('%Y-%m', created_at) = ?
      AND user_code = ?
      AND debt_id = ?
    ''',
      [
        currentMonth,
        UserToken.user_code,
        id
      ], // Use parameterized query for safety
    );

    // Extract the sum from the query result
    double totalAmount = -(result.first['total'] ?? 0.0);

    month_total_expense = totalAmount;
  }

  static Future<int> insertDebt(Debt debt) async {
    return await DatabaseHelper().insertData(table, debt.toMap());
  }

  static Future<int> updateDebt(Debt debt) async {
    if (debt.remaining_month == 0) {
      debt.desc = "Debt Pay Off";
      debt.status = false;
    }
    return await DatabaseHelper().updateData(table, debt.toMap(), debt.id!);
  }

  static Future<int> deleteDebt(int id, bool hardDelete) async {
    var db = await DatabaseHelper().database;

    if (hardDelete) {
      return await DatabaseHelper().deleteData(table, id);
    } else {
      return await db.update(
        table,
        {'status': 0}, // Update status to false (0)
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  static Future<(double, int)> getTotalDebt() async {
    var db = await DatabaseHelper().database;

    // Get the current date to check against the last_paid_date
    final DateTime now = DateTime.now();

    // Query to calculate the sum of 'monthly_payment' column in the 'Debt' table
    String currentMonth =
        DateTime.now().toString().substring(0, 7); // Format as 'YYYY-MM'
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(monthly_payment) as total FROM $table WHERE status = 1 AND (strftime("%Y-%m", last_payment_date) != ? OR last_payment_date IS NULL) and user_code = "${UserToken.user_code}"',
      [currentMonth],
    );

    final List<Map<String, dynamic>> count = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $table WHERE status = 1 AND (strftime("%Y-%m", last_payment_date) != ? OR last_payment_date IS NULL) and user_code = "${UserToken.user_code}" and type != "Expenses"',
      [currentMonth],
    );

    // Retrieve the sum from the query result

    double totalDebt = result.first['total'] ?? 0.00;
    int unpaidDebt = count.first['total'] ?? 0;

    return (totalDebt, unpaidDebt);
  }

  static Future<List<Debt>> getDebtList() async {
    var db = await DatabaseHelper().database;

    // Query the database for all debts
    final List<Map<String, dynamic>> maps = await db.query(table,
        where:
            'status = 1 and user_code = "${UserToken.user_code}"' // Replace with the specific month-year you want to filter
        );

    // Convert the List<Map<String, dynamic>> into List<Debt>
    var list = List.generate(maps.length, (i) {
      return Debt(maps[i]['user_code'],
          id: maps[i]['id'],
          name: maps[i]['name'],
          type: maps[i]['type'],
          monthly_payment: maps[i]['monthly_payment'],
          remaining_month: maps[i]['remaining_month'],
          total_month: maps[i]['total_month'],
          status: maps[i]['status'] == 1,
          desc: maps[i]['desc'],
          last_payment_date: maps[i]['last_payment_date'] != null
              ? DateTime.parse(maps[i]
                  ['last_payment_date']) // Convert ISO string back to DateTime
              : null,
          alarming_limit: maps[i]['alarming_limit'] != null
              ? maps[i]['alarming_limit'] as double
              : -1);
    });

    await Future.wait(list
        .where((e) => e.type == 'Expenses')
        .map((e) => e.getMonthlyTotal()));

    return list;
  }

  static Future<Debt?> getDebtById(int debtId) async {
    var db = await DatabaseHelper().database;

    // Query the database for a debt with the given id
    final List<Map<String, dynamic>> maps = await db.query(
      table, // The table name for debts
      where: 'id = ?', // Filter by debt id
      whereArgs: [debtId], // Provide the debt id as a parameter
    );

    // If the result is empty, return null (debt not found)
    if (maps.isNotEmpty) {
      // Return the debt by mapping the first result
      return Debt(maps[0]['user_code'],
          id: maps[0]['id'],
          name: maps[0]['name'],
          type: maps[0]['type'],
          monthly_payment: maps[0]['monthly_payment'],
          remaining_month: maps[0]['remaining_month'],
          total_month: maps[0]['total_month'],
          status: maps[0]['status'] == 1, // Convert from 0/1 to boolean
          desc: maps[0]['desc'],
          last_payment_date: maps[0]['last_payment_date'] != null
              ? DateTime.parse(maps[0]
                  ['last_payment_date']) // Convert ISO string back to DateTime
              : null,
          alarming_limit: maps[0]['alarming_limit'] != null
              ? maps[0]['alarming_limit'] as double
              : -1);
    }

    // Return null if no debt is found
    return null;
  }
}
