import 'dart:convert';
import 'package:build_growth_mobile/models/user_token.dart';
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

  GoldenLeaf(
      {required this.totalSubLeaf,
      this.user_code,
      this.date,
      this.chatRequest});

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
      chatRequest: map['chatRequest'],
    );
  }

  /// Converts a GoldenLeaf object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'user_code': user_code,
      'chatRequest': chatRequest,
      'totalSubLeaf': totalSubLeaf,
    };
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
      leaf.totalSubLeaf = await GoldenLeaf.getSubLeaf(DateTime.now());
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

  /// Deletes the GoldenLeaf object from SharedPreferences
  static Future<void> clearFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('goldenLeaf');
  }

  static Future<int> getSubLeaf(DateTime date) async {
    int sum_leaf = 0;

    var t_data = await Transaction.getTransactionList();
    var t_transaction_list = t_data.$1;

    var t_count = t_transaction_list
        .where((x) => FormatterHelper.isToday(x.created_at))
        .length;

    if (t_count >= 1) {
      sum_leaf++;
    }

    if (t_count >= 3) {
      sum_leaf++;
    }

    if (t_count >= 5) {
      sum_leaf++;
    }

    var content_enroll = await ContentRepo.getAttendanceHistory();
    var content_viewed = await ContentRepo.getViewContents();

    var content_count = content_enroll
            .where((x) => FormatterHelper.isToday(x.update_at))
            .length +
        content_viewed
            .where((x) => FormatterHelper.isToday(x.update_at))
            .length;

    if (content_count >= 1) {
      sum_leaf++;
    }

    if (content_count >= 2) {
      sum_leaf++;
    }

    if (content_count >= 3) {
      sum_leaf++;
    }

    return sum_leaf;
  }
}
