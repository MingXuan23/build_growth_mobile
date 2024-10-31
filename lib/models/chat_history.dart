
import 'package:build_growth_mobile/services/database_helper.dart';

class Chat_History {
  final int? id;
  final String request;
  final String response;
  final int? transaction_id;
  final DateTime create_at;
  final String status;
  final String? user_code;

  Chat_History(this.create_at, this.status, this.user_code, { this.id, required this.request, required this.response, required this.transaction_id});

  Map<String, dynamic> toMap() {
    return {
     
      'request': request,
      'response': response,
      'transaction_id': transaction_id,
      'create_at': create_at.toIso8601String(),
      'status': status,
      'user_code': user_code
    };
  }

  static Future<int> insertChatHistory(Chat_History chatHistory) async {
    return await DatabaseHelper().insertData('Chat_History', chatHistory.toMap());
  }

  static Future<int> updateChatHistory(Chat_History chatHistory) async {
    return await DatabaseHelper().updateData('Chat_History', chatHistory.toMap(), chatHistory.id!);
  }

  static Future<int> deleteChatHistory(int id) async {
    return await DatabaseHelper().deleteData('Chat_History', id);
  }
}
