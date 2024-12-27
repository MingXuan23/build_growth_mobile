import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/services/database_helper.dart';

class Chat_History {
  int? id;
  final String request;
  final String response;
  final int? transaction_id;
  final DateTime create_at;
  final String status;
  final String? user_code;

  Chat_History(
    this.create_at,
    this.status,
    this.user_code, {
    this.id,
    required this.request,
    required this.response,
    required this.transaction_id,
  });

  static final String table = 'Chat_History';
  Map<String, dynamic> toMap() {
    return {
      'request': request,
      'response': response,
      'transaction_id': transaction_id,
      'create_at': create_at.toIso8601String(),
      'status': status,
      'user_code': UserToken.user_code
    };
  }

  static Future<int> insertChatHistory(Chat_History chatHistory) async {
    return await DatabaseHelper()
        .insertData('Chat_History', chatHistory.toMap());
  }

  static Future<int> updateChatHistory(Chat_History chatHistory) async {
    return await DatabaseHelper()
        .updateData('Chat_History', chatHistory.toMap(), chatHistory.id!);
  }

  static Future<int> deleteChatHistory(int id) async {
    return await DatabaseHelper().deleteData('Chat_History', id);
  }

  static Future<List<Chat_History>> getChatList() async {
    var db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'status = ? AND user_code = ?',
      whereArgs: ['1', UserToken.user_code],
    );

    // Convert the List<Map<String, dynamic>> into List<Asset>
    return List.generate(maps.length, (i) {
      return Chat_History(
          id: maps[i]['id'],
          DateTime.parse(maps[i]['create_at']),
          maps[i]['status'],
          maps[i]['user_code'],
          request: maps[i]['request'],
          response: maps[i]['response'],
          transaction_id: maps[i]['transaction_id']);
    });
  }
}
