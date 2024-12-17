import 'dart:convert';
import 'dart:math';

import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class UserBackup {
  static DateTime? lastBackUpTime;

  static List<String> data = [];

  static Future<String> getUserBackUp(String userCode) async {
    var db = await DatabaseHelper().database;

    // Helper function to fetch rows with remaining row limit
    Future<List<Map<String, dynamic>>> fetchRows(
        String tableName, String userCode) async {
      return await db.query(
        tableName,
        where: 'user_code = ?',
        whereArgs: [userCode],
      );
    }

    // Fetch data from each table with remaining rows
    final List<Map<String, dynamic>> assetRows =
        await fetchRows('Asset', userCode);

    final List<Map<String, dynamic>> debtRows =
        await fetchRows('Debt', userCode);

    final List<Map<String, dynamic>> transactionRows =
        await fetchRows('Transactions', userCode);

    final List<Map<String, dynamic>> chat_history =
        await fetchRows('Chat_History', userCode);

    // Prepare the result as a JSON string
    final Map<String, dynamic> result = {
      'assets': assetRows,
      'debts': debtRows,
      'transactions': transactionRows,
      'chat_history': chat_history
    };

    var res = jsonEncode(result);
    return res;
  }

  static Future<Map<String, dynamic>> getData() async {
    var latest_info = await getUserBackUp(UserToken.user_code ?? '');
    Map<String, dynamic> data = {
      'data': latest_info,
      'user_code': UserToken.user_code
    };

    final data_string = jsonEncode(data);
    final random = new Random();
    final salt = String.fromCharCodes(
      List.generate(40,
          (index) => random.nextInt(26) + 97), // 97 is the ASCII value of 'a'
    );

    final value = encrypt(data_string, salt);
    //final value = encrypt('{"1","2","3","4"}', salt);

    Map<String, dynamic> backupString = {
      'backup_at': DateTime.now().toString().substring(0, 16),
      'value': value,
      'salt': salt
    };

    return (backupString);
  }

  static Future<void> restoreData(Map<String, dynamic> backupString) async {
    try {
      var data = decrypt(backupString['value'], backupString['salt']);
      var backup = jsonDecode(data);

      if (backup['user_code'] != UserToken.user_code) {
        throw Exception(
            'Modified Data or You are not the owner of this backup');
      }


      var data_to_restore = jsonDecode(backup['data']);

      // Get the database instance
      var db = await DatabaseHelper().database;
      // Restore assets
      await _restoreTable(
          db, 'Asset', data_to_restore['assets'], 'id', UserToken.user_code??'');

      // Restore debts
      await _restoreTable(
          db, 'Debt', data_to_restore['debts'], 'id', UserToken.user_code??'');

      // Restore transactions
      await _restoreTable(db, 'Transactions', data_to_restore['transactions'],
          'id', UserToken.user_code??'');

      // Restore chat history
      await _restoreTable(db, 'Chat_History', data_to_restore['chat_history'], 'id',
          UserToken.user_code??'');

      print("Data restored successfully.");
    } catch (e) {
      throw Exception('Modified Data or You are not the owner of this backup');
    }
  }

  static Future<void> _restoreTable(Database db, String tableName,
      List<dynamic> backupData, String primaryKey, String userCode) async {
    // Fetch existing rows for the user from the database
    final List<Map<String, dynamic>> existingRows = await db.query(
      tableName,
      where: 'user_code = ?',
      whereArgs: [userCode],
    );

    // Convert existing rows to a map for easier lookup by primary key
    Map<dynamic, Map<String, dynamic>> existingMap = {
      for (var row in existingRows) row[primaryKey]: row
    };

    // Convert backup data to a map for easier lookup by primary key
    Map<dynamic, Map<String, dynamic>> backupMap = {
      for (var row in backupData) row[primaryKey]: row
    };

    // Delete rows that are in the database but not in the backup
    for (var existingId in existingMap.keys) {
      if (!backupMap.containsKey(existingId)) {
        await db.delete(
          tableName,
          where: '$primaryKey = ? AND user_code = ?',
          whereArgs: [existingId, userCode],
        );
      }
    }

    // Insert new rows or update existing rows
    for (var backupRow in backupData) {
      var primaryKeyValue = backupRow[primaryKey];
      if (existingMap.containsKey(primaryKeyValue)) {
        // Update the existing row
        await db.update(
          tableName,
          backupRow,
          where: '$primaryKey = ? AND user_code = ?',
          whereArgs: [primaryKeyValue, userCode],
        );
      } else {
        // Insert a new row
        await db.insert(tableName, backupRow);
      }
    }
  }

// reverse
  static List<String> reverse(List<String> array, int seed) {
    int new_seed = max(3, seed % (array.length / 3).floor());

    int n = new_seed;

    while (n < array.length) {
      List<String> temp = [];

      var res1 = array.sublist(0, n);

      var res2 = array.sublist(n);
      temp.addAll(res1.reversed.toList());

      temp.addAll(res2.reversed.toList());
      array = temp;
      n += new_seed;
    }

    return array;
  }

  static List<String> restore(List<String> array, int seed) {
    int new_seed = max(3, seed % (array.length / 3).floor());

    int max_n = (array.length / new_seed).floor();

    while (max_n > 0) {
      List<String> temp = [];

      var res1 = array.sublist(0, max_n * new_seed);

      var res2 = array.sublist(max_n * new_seed);
      temp.addAll(res1.reversed.toList());

      temp.addAll(res2.reversed.toList());
      array = temp;
      max_n--;
    }

    return array;
  }

  static List<String> getSubstringsOverValue(String str, int value) {
    List<String> result = [];
    int sum = 0;
    int start = 0;

    for (int i = 0; i < str.length; i++) {
      sum += str.codeUnitAt(i);
      if (sum > value || str[i] == '^') {
        result.add(str.substring(start, i + 1));
        sum = 0;
        start = i + 1;
      } else if (i == str.length - 1) {
        result.add(str.substring(start, i + 1) + '^');
      }
    }

    return result;
  }

  static String encrypt(String dataString, String salt) {
    // Main encryption steps based on the JavaScript code
    String key = salt; // Key for Vigenère cipher
    int value = 5 * log(double.parse(UserToken.user_code ?? '1')).floor();
    List<String> resultArray = getSubstringsOverValue(dataString, value);

    var res1 = reverse(resultArray, value);

    String encrypted = vigenereFunc(res1.join(''), key);

    return encrypted;
  }

  static String decrypt(String dataString, String salt) {
    // Process the decrypted string with the same logic as shown in JavaScript
    var result = vigenereDecryptFunc(dataString, salt);
    int value = 5 * log(double.parse(UserToken.user_code ?? '1')).floor();
    List<String> processArray = getSubstringsOverValue(result, value);
    result = restore(processArray, (value))
        .join('')
        .replaceAll(RegExp(r'(\^)(?!.*\^)'), "");

    return result;
  }

// 5. Vigenère cipher function
  static String vigenereFunc(String plainText, String key) {

    var letters = shuffleString(LETTERS, seed:  int.parse(UserToken.user_code??'0'));
    String cipherText = "";
    int j = 0;

    for (int i = 0; i < plainText.length; i++) {
      String char = plainText[i];
      if (!letters.contains(char)) {
        cipherText += char;
        continue;
      }

      int currentIndex = letters.indexOf(char);
      int keyIndex = letters.indexOf(key[j % key.length]);
      int encryptedIndex = (currentIndex + keyIndex) % letters.length;
      cipherText += letters[encryptedIndex];

      j++;
    }

    return cipherText;
  }

  static String vigenereDecryptFunc(String cipherText, String key) {
    var letters = shuffleString(LETTERS, seed:  int.parse(UserToken.user_code??'0'));
    String decryptedText = "";
    int j = 0;

    for (int i = 0; i < cipherText.length; i++) {
      String char = cipherText[i];
      if (!letters.contains(char)) {
        decryptedText += char;
        continue;
      }

      int currentIndex = letters.indexOf(char);
      int keyIndex = letters.indexOf(key[j % key.length]);
      int decryptedIndex =
          (currentIndex - keyIndex + letters.length) % letters.length;
      decryptedText += letters[decryptedIndex];

      j++;
    }

    return decryptedText;
  }

  

static String shuffleString(String input, {int seed = 0}) {
  // Convert the string to a list of characters
  List<String> chars = input.split('');
  
  // Create a seeded Random instance
  Random random = Random(seed);
  
  // Shuffle the list with the seeded Random
  chars.shuffle(random);
  
  // Join the shuffled list back to a string
  return chars.join();
}

}

