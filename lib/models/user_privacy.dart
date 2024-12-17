import 'dart:convert';
import 'dart:math';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/user_backup.dart';
import 'package:build_growth_mobile/services/backup_helper.dart';
import 'package:build_growth_mobile/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrivacy {
  static bool useGPT = true;
  static bool pushContent = true;
  //static String backUpFrequency = "First Transaction In A Day";

  static bool googleDriveBackup = false;

  // static String backUpFrequency = "No Backup";

  // static String backUpFrequency = "First Transaction In A Month";
  // static String backUpFrequency = "Every Transaction";

  // Convert the current settings to a Map
  static Map<String, dynamic> toMap() {
    return {
      'useGPT': useGPT,
      'useContent': pushContent,
      'useGoogleDriveBackup': googleDriveBackup,
    };
  }

  static void fromMap(Map<String, dynamic> map) {
    useGPT = map['useGPT'] ?? false;
    pushContent = map['useContent'] ?? false;
    googleDriveBackup = map['useGoogleDriveBackup'] ?? false;
  }

  // Save settings as JSON to SharedPreferences
  static Future<void> saveToPreferences(String usercode) async {
    if (googleDriveBackup) {
      var result = await GoogleDriveBackupHelper.initialize();
      if(!result){
        UserPrivacy.googleDriveBackup = false;
         throw new Exception('Error in login to Google Drive') ;
      }
    } else {
      await GoogleDriveBackupHelper.signOut();
    }


    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(toMap());
    await prefs.setString('user_privacy_$usercode', jsonString);
  }

  // Load settings from JSON in SharedPreferences
  static Future<void> loadFromPreferences(String usercode) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user_privacy_$usercode');
    if (jsonString != null) {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      fromMap(map);
    }
  }

  static Future<Map<String, dynamic>> getUserSummary(String userCode) async {
    // if (backUpFrequency == 'No Backup') {
    //   return {};
    // }

    if (!useGPT) {
      return {};
    }

    var db = await DatabaseHelper().database;
    const int maxRows = 10000; // Maximum rows limit
    int remainingRows = maxRows; // Remaining rows available for queries

    // Fetch key information only from each table
    final List<Map<String, dynamic>> assetRows = await db.query(
      'Asset',
      columns: ['name', 'value', 'type', 'status'], // Select key fields
      where: 'user_code = ? and status = 1 ',
      whereArgs: [userCode],
      limit: remainingRows,
    );

    remainingRows -= assetRows.length;

    final List<Map<String, dynamic>> debtRows = await db.query(
      'Debt',
      columns: [
        'name',
        'monthly_payment',
        'remaining_month',
        "CASE WHEN strftime('%Y-%m', last_payment_date) = strftime('%Y-%m', 'now') THEN 'Paid' ELSE 'Unpaid' END AS status"
      ],
      where: 'user_code = ? AND remaining_month > 0',
      whereArgs: [userCode],
      limit: remainingRows,
    );

    remainingRows -= debtRows.length;

    final String query = '''
  SELECT 
    Transactions.amount,
    Asset.name AS asset_name,
    Debt.name AS debt_name,
   SUBSTR(Transactions.created_at, 1, 10) AS created_at,
    CASE 
      WHEN Transactions.amount >= 0 THEN 'Income'
      ELSE 'Expense' 
    END AS transaction_type
  FROM Transactions
  LEFT JOIN Asset ON Transactions.asset_id = Asset.id
  LEFT JOIN Debt ON Transactions.debt_id = Debt.id
  WHERE Transactions.user_code = ? AND Transactions.transaction_type != 2
    AND DATE(Transactions.created_at) >= DATE('now', '-2 months')
  ORDER BY (Transactions.created_at) DESC
  LIMIT $remainingRows
''';

    final List<Map<String, dynamic>> transactionRows =
        await db.rawQuery(query, [userCode]);

    double totalIncome = transactionRows
        .where((transaction) => transaction['transaction_type'] == 'Income')
        .fold(0.0, (sum, transaction) => sum + (transaction['amount'] ?? 0));

    double totalExpense = transactionRows
        .where((transaction) => transaction['transaction_type'] == 'Expense')
        .fold(0.0, (sum, transaction) => sum + (transaction['amount'] ?? 0));
    var cash_flow = await Asset.getTotalCashFlow();
    var total_asset = await Asset.getTotalAsset();

    double cash_flow_percent = totalIncome * 100 / max(totalExpense.abs(), 100);
    int financial_freedom = (total_asset / ((max(totalExpense.abs(), 900)) / 3))
        .floor(); //the month can survive without work
    String tone = '';

    if (cash_flow_percent <= -30 || financial_freedom <= 0) {
      // Most negative
      tone =
          'You are deeply concerned about my spending habits and lack of savings. Please give an immediate and extremely stern warning, using mindset of the poor dad';
    } else if (cash_flow_percent <= -10) {
      tone =
          'You are seriously worried about my spending behavior and insufficient savings. Please provide a serious warning,  using mindset of the poor dad."';
    } else if (cash_flow_percent <= 0 || financial_freedom <= 1) {
      tone =
          'You are concerned about my spending habits and limited savings. Please provide firm and practical advice,  using mindset of the poor dad"';
    } else if (cash_flow_percent <= 10) {
      tone =
          'You believe I should prioritize increasing my savings. Please give constructive advice, using mindset of the poor dad';
    } else if (cash_flow_percent <= 30 || financial_freedom <= 2) {
      tone =
          'You are pleased to see that my savings and income are stable. Please provide neutral feedback, using mindset of the poor dad';
    } else if (cash_flow_percent <= 50) {
      tone =
          'You are happy that I have adequate cash flow. Please provide simple positive feedback using the Rich Dad mindset.';
    } else if (cash_flow_percent <= 70 || financial_freedom <= 4) {
      tone =
          'You are delighted that I have enough assets and cash flow. Please provide positive feedback using the Rich Dad mindset.';
    } else if (cash_flow_percent <= 100) {
      tone =
          'You are impressed by my growing cash flow. Please provide uplifting feedback using the Rich Dad mindset.';
    } else if (cash_flow_percent <= 150 || financial_freedom <= 6) {
      tone =
          'You are proud of my ability to grow my finances. Please provide encouraging suggestions using the Rich Dad mindset.';
    } else if (cash_flow_percent <= 300 || financial_freedom <= 12) {
      tone =
          'You are inspired by my financial progress. Please provide inspirational suggestions using the Rich Dad mindset.';
    } else {
      // Most positive
      tone =
          'You are amazed by my exceptional financial success. Please provide highly motivational suggestions using the Rich Dad mindset.';
    }

    // Prepare the result as a JSON string
    final Map<String, dynamic> result = {
      'assets': assetRows,
      'debts': debtRows,
      'transactions': transactionRows,
      'cash_flow': cash_flow,
      'currency': "RM",
      'time_now': DateTime.now().toString().substring(0, 16),
      'tone': tone
    };

    return result;
  }
}
