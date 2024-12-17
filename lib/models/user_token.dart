import 'dart:convert';
import 'package:build_growth_mobile/models/user_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserToken {
  static String? email;
//  static String? name;
  static String? user_code;
  static String? remember_token;
  static String? device_token;
  static bool online = false;
  static bool gptReady = false;

  // Convert the UserToken to a JSON map
  static Map<String, dynamic> toJson() {
    return {
      'email': email,
      'user_code': user_code,
      'remember_token': remember_token,
      'device_token': device_token,
      'last_backup': UserBackup.lastBackUpTime?.toIso8601String()
    };
  }

  static void initialise(
      {String? email,
      String? user_code,
      String? remember_token,
      String? device_token}) {
    UserToken.email = email;
    UserToken.user_code = user_code;

    UserToken.remember_token = remember_token;

    UserToken.device_token = device_token ?? UserToken.device_token;
    online = true;
  }

  // Load the UserToken from a JSON map
  static void fromJson(Map<String, dynamic> json) {
    email = json['email'];
    user_code = json['user_code'];
    remember_token = json['remember_token'];
    device_token = device_token ?? json['device_token'];

    if (json['last_backup'] != null) {
      UserBackup.lastBackUpTime = DateTime.parse(json['last_backup']);
    }
  }

  // Save the UserToken to SharedPreferences
  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(toJson());
    await prefs.setString('user_token', jsonString);
  }

  // Load the UserToken from SharedPreferences
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user_token');
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      fromJson(jsonMap);
    }
  }

  // Clear the UserToken from SharedPreferences
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();

    user_code = null;
    remember_token = null;

    await save();
  }
}
