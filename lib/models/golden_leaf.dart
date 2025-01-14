import 'dart:convert';
import 'package:build_growth_mobile/models/user_backup.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/services/backup_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:build_growth_mobile/api_services/content_repo.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';

class GoldenLeaf {
  int? id;
  DateTime? date;
  final String? user_code;
  List<DateTime>? chatRequest;
  int totalSubLeaf;
  DateTime? shareTime;

  GoldenLeaf(
      {required this.totalSubLeaf,
      this.user_code,
      this.date,
      this.chatRequest,
      this.shareTime});

  void addChatRequest() {
    if (chatRequest == null) {
      chatRequest = [DateTime.now()];
    } else {
      chatRequest!.add(DateTime.now());
    }
  }

  /// Converts a Map to a GoldenLeaf object
  factory GoldenLeaf.fromMap(Map<String, dynamic> map) {
    return GoldenLeaf(
      totalSubLeaf: map['totalSubLeaf'] ?? 0,
      user_code: map['user_code'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      shareTime:
          map['shareTime'] != null ? DateTime.parse(map['shareTime']) : null,
      chatRequest: map['chatRequest'] != null
          ? (jsonDecode(map['chatRequest']) as List<dynamic>)
              .map((e) => DateTime.parse(e as String))
              .toList()
          : [],
    );
  }

  /// Converts a GoldenLeaf object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date?.toIso8601String(), // Use ISO8601 for consistency
      'user_code': user_code,
      'chatRequest': chatRequest != null
          ? jsonEncode(chatRequest!.map((x) => x.toIso8601String()).toList())
          : null, // Ensure proper serialization
      'totalSubLeaf': totalSubLeaf,
      'shareTime': shareTime?.toIso8601String()
    };
  }

  Map<String, dynamic> toBugMap() {
    return {
      'date': date?.toIso8601String(), // Use ISO8601 for consistency

      'chatRequest': chatRequest != null
          ? jsonEncode(chatRequest!.map((x) => x.toIso8601String()).toList())
          : null, // Ensure proper serialization
      'totalSubLeaf': totalSubLeaf,
      'shareTime': shareTime?.toIso8601String()
    };
  }

  static Future<void> saveLocalLeafData(Map<String, dynamic> leafData) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(leafData);
    await prefs.setString('golden_leafdata_${UserToken.user_code}', jsonString);
  }

  static Future<Map<String, dynamic>> getLocalLeafData() async {
    final prefs = await SharedPreferences.getInstance();

    var json = prefs.getString('golden_leafdata_${UserToken.user_code}');

    var leafData = jsonDecode(json ?? '{}') as Map<String, dynamic>;

    return leafData;
  }

  /// Saves the GoldenLeaf object into SharedPreferences
  Future<void> saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(toMap());
    if (!FormatterHelper.isToday(date)) {
      var newChatReq =
          chatRequest?.where((x) => FormatterHelper.isToday(x)).toList();
      GoldenLeaf leaf = GoldenLeaf(
          totalSubLeaf: 0,
          date: DateTime.now(),
          user_code: UserToken.user_code,
          chatRequest: newChatReq);

      var data = await GoldenLeaf.getSubLeaf(leaf.chatRequest, shareTime);

      leaf.totalSubLeaf = data['sum_leaf'];
      jsonString = jsonEncode(leaf);
    }

    await prefs.setString('golden_leaf_${UserToken.user_code}', jsonString);
  }

  /// Retrieves the GoldenLeaf object from SharedPreferences
  static Future<GoldenLeaf?> loadFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('golden_leaf_${UserToken.user_code}');
    if (jsonString == null) return null;

    Map<String, dynamic> map = jsonDecode(jsonString);

    var leaf = GoldenLeaf.fromMap(map);

    if (FormatterHelper.isToday(leaf.date)) {
      return leaf;
    }

    return null;
  }

  static Future<void> deleteFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('golden_leaf_${UserToken.user_code}');
  }

  static Future<Map<String, dynamic>> getSubLeaf(
      List<DateTime>? chatRequest, DateTime? shareTime) async {
    List<String> completedMissionList = [];
    List<String> pendingMissionList = [];
    int sum_leaf = 0;

    var t = await Transaction.getTransactionList(
        month: DateTime.now().month, year: DateTime.now().year);
    // Fetch data in parallel
    final results = await Future.wait([
      GoogleDriveBackupHelper.readJsonFile(),
      ContentRepo.getAttendanceHistory(),
      ContentRepo.getViewContents(),
    ]);

    // Extract results
    var t_transaction_list = t.$1 as List<dynamic>;
    var backups = results[0] as List<Map<String, dynamic>>;
    var content_enroll = results[1] as List<dynamic>;
    var content_viewed = results[2] as List<dynamic>;

    // Calculate today's transactions
    var t_count = t_transaction_list
        .where((x) => FormatterHelper.isToday(x.created_at))
        .length;

    // Backup logic
    var isBackUpToday = FormatterHelper.isToday(UserBackup.lastBackUpTime) ||
        backups.any((backup) =>
            FormatterHelper.isToday(DateTime.tryParse(backup['backup_at'])));

    if (isBackUpToday) {
      sum_leaf++;
      completedMissionList.add('Backup Today: 1/1');
    } else {
      pendingMissionList.add('Backup Today: 0/1');
    }

    // Transaction logic
    if (t_count >= 1) {
      sum_leaf++;
      completedMissionList.add('Transaction Recorded: $t_count/1');
    } else {
      pendingMissionList.add('Transaction Recorded: $t_count/1');
    }

    // Content interaction logic
    var content_count = content_enroll
            .where((x) => FormatterHelper.isToday(x.update_at))
            .length +
        content_viewed
            .where((x) => FormatterHelper.isToday(x.update_at))
            .length;

    if (content_count >= 1) {
      sum_leaf++;
      completedMissionList.add('Content Enrolled or Viewed: $content_count/1');
    } else {
      pendingMissionList.add('Content Enrolled or Viewed: $content_count/1');
    }

    if (content_count >= 2) {
      sum_leaf++;
      completedMissionList.add('Content Enrolled or Viewed: $content_count/2');
    } else {
      pendingMissionList.add('Content Enrolled or Viewed: $content_count/2');
    }

    if (content_count >= 3) {
      sum_leaf++;
      completedMissionList.add('Content Enrolled or Viewed: $content_count/3');
    } else {
      pendingMissionList.add('Content Enrolled or Viewed: $content_count/3');
    }

    // Chat logic
    var today_chat =
        chatRequest?.where((x) => FormatterHelper.isToday(x)).length ?? 0;

    if (today_chat >= 1) {
      sum_leaf++;
      completedMissionList.add('Chat with xBUG AI: $today_chat/1');
    } else {
      pendingMissionList.add('Chat with xBUG AI: $today_chat/1');
    }

    if (today_chat >= 3) {
      sum_leaf++;
      completedMissionList.add('Chat with xBUG AI: $today_chat/3');
    } else {
      pendingMissionList.add('Chat with xBUG AI: $today_chat/3');
    }

    if (FormatterHelper.isToday(shareTime)) {
      sum_leaf++;
      completedMissionList.add('Share Your Golden Leaf: 1/1');
    } else {
      pendingMissionList.add('Share Your Golden Leaf: 0/1');
    }

    // Return the result as a Map
    return {
      'sum_leaf': sum_leaf,
      'completedMissions': completedMissionList,
      'pendingMissions': pendingMissionList,
    };
  }
}
