import 'package:build_growth_mobile/services/database_helper.dart';

class Debt {
  static const String table = 'Debt';
  final int? id;
  String name;
  String type; // Removed total_amount as it's not in the database schema
  double monthly_payment;
  int remaining_month;
  int total_month;
  bool
      status; // Changed from bool to int to match the database structure (0 or 1)
  String? desc; // Make desc nullable if it can be null
  final String? user_code;
  DateTime? last_payment_date; // Added last_payment as a nullable DateTime

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
    this.last_payment_date, // Added last_payment to constructor
  });

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
      'user_code': user_code,
      'last_payment_date': last_payment_date
          ?.toIso8601String(), // Convert DateTime to ISO string for storage
    };
  }

  static Future<int> insertDebt(Debt debt) async {
    return await DatabaseHelper().insertData(table, debt.toMap());
  }

  static Future<int> updateDebt(Debt debt) async {

    if(debt.remaining_month == 0){
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

  static Future<double> getTotalDebt() async {
    var db = await DatabaseHelper().database;

    // Get the current date to check against the last_paid_date
    final DateTime now = DateTime.now();

    // Query to calculate the sum of 'monthly_payment' column in the 'Debt' table
    String currentMonth =
        DateTime.now().toString().substring(0, 7); // Format as 'YYYY-MM'
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(monthly_payment) as total FROM $table WHERE status = 1 AND (strftime("%Y-%m", last_payment_date) != ? OR last_payment_date IS NULL)',
      [currentMonth],
    );

    // Retrieve the sum from the query result
    double totalDebt = result.first['total'] ?? 0.0;

    return totalDebt;
  }

  static Future<List<Debt>> getDebtList() async {
    var db = await DatabaseHelper().database;
    
    // Query the database for all debts
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where:
          'status = 1' // Replace with the specific month-year you want to filter
    );

    // Convert the List<Map<String, dynamic>> into List<Debt>
    return List.generate(maps.length, (i) {
      return Debt(
        maps[i]['user_code'],
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
      );
    });
  }
}
