import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrivacy {
  static bool useGPT = false;
  static bool pushContent = true;
  static String backUpFrequency = "First Transaction In A Day";
  // static String backUpFrequency = "No Backup";

  // static String backUpFrequency = "First Transaction In A Month";
  // static String backUpFrequency = "Every Transaction";

  // Convert the current settings to a Map
  static Map<String, dynamic> toMap() {
    return {
      'useGPT': useGPT,
      'pushContent': pushContent,
    };
  }

  // Update settings from a Map
  static void fromMap(Map<String, dynamic> map) {
    useGPT = map['useGPT'] ?? false;
    pushContent = map['pushContent'] ?? false;
  }

  // Save settings as JSON to SharedPreferences
  static Future<void> saveToPreferences(String usercode) async {
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
}
