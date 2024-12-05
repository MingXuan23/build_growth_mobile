import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/api_services/gpt_repo.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/services/database_helper.dart';

class Asset {
  static const String table = 'Asset';
  final int? id;
  String name;
  double value;
  String desc;
  String type;
  bool status;
  String? unique_code;
  final String? user_code;

  Asset(this.user_code,
      {this.id,
      required this.name,
      required this.value,
      required this.desc,
      required this.type,
      required this.status,
      this.unique_code});

  // Convert Asset object to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'desc': desc,
      'type': type,
      'status': status ? 1 : 0, // Store bool as int
      'user_code': UserToken.user_code,
      'unique_code': unique_code
    };
  }

  factory Asset.fromMap(Map<String, dynamic> maps) {
    return Asset(maps['user_code'],
        id: maps['id'], // Include the id here
        name: maps['name'],
        value: maps['value'],
        desc: maps['desc'],
        type: maps['type'],
        status: maps['status'] == 1, // Convert from 0/1 to boolean
        unique_code: maps['unique_code'] ?? '');
  }

  // Insert Asset
  static Future<int> insertAsset(Asset asset) async {
    var prompt =
        'I have ${asset.name} (${asset.type}) with ${asset.value}. Give positive feedback using rich dad mindset.';
    var desc = await GptRepo.slowResponse(prompt, 15);
    asset.desc = desc ?? asset.desc;
    return await DatabaseHelper().insertData(table, asset.toMap());
  }

  // Update Asset
  static Future<int> updateAsset(Asset asset, {Transaction? t}) async {
    if (t != null) {
      
      var prompt = await t.promptFromTransaction();

      var desc = await GptRepo.slowResponse(prompt, 15);
      asset.desc = desc ?? asset.desc;
    }

    return await DatabaseHelper().updateData(table, asset.toMap(), asset.id!);
  }

  // Delete Asset
  static Future<int> deleteAsset(int id, bool hardDelete) async {
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

  static Future<double> getTotalAsset() async {
    var db = await DatabaseHelper().database;

    // Query to calculate the sum of 'value' column in the 'Asset' table
    final List<Map<String, dynamic>> result = await db
        .rawQuery('SELECT SUM(value) as total FROM $table where status = 1 and user_code = ${UserToken.user_code}');

    // Retrieve the sum from the query result
    double totalAssets = result.first['total'] ?? 0.0;

    return totalAssets;
  }

  static Future<List<Asset>> getAssetList() async {
    var db = await DatabaseHelper().database;

    // Query the database for all assets with status true (1)
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'status = 1 and  user_code = ${UserToken.user_code}',
      //whereArgs: [1, UserToken.user_code], // Filter for assets with status true (1)
    );

    // Convert the List<Map<String, dynamic>> into List<Asset>
    return List.generate(maps.length, (i) {
      return Asset(maps[i]['user_code'],
          id: maps[i]['id'], // Include the id here
          name: maps[i]['name'],
          value: maps[i]['value'],
          desc: maps[i]['desc'],
          type: maps[i]['type'],
          status: maps[i]['status'] == 1, // Convert from 0/1 to boolean
          unique_code: maps[i]['unique_code'] ?? '');
    });
  }

  static Future<Asset?> getAssetById(int assetId) async {
    var db = await DatabaseHelper().database;

    // Query the database for an asset with the given id
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'id = ?', // Filter by asset id
      whereArgs: [assetId], // Provide the asset id as a parameter
    );

    // If the result is empty, return null (asset not found)
    if (maps.isNotEmpty) {
      // Return the asset by mapping the first result
      return Asset(
        maps[0]['user_code'],
        id: maps[0]['id'],
        name: maps[0]['name'],
        value: maps[0]['value'],
        desc: maps[0]['desc'],
        type: maps[0]['type'],
        status: maps[0]['status'] == 1, // Convert from 0/1 to boolean
        unique_code: maps[0]['unique_code'] ?? '', // Handle null unique_code
      );
    }

    // Return null if no asset is found
    return null;
  }

  static Future<Asset?> getBankCardByUniqueCode(String code) async {
    var db = await DatabaseHelper().database;

    // Query the database for all assets with status true (1)
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'status = ? and type = ? and unique_code = ?',
      whereArgs: [
        1,
        "Bank Card",
        code
      ], // Filter for assets with status true (1)
    );

    if (maps.isNotEmpty) {
      return Asset.fromMap(maps.first);
    }

    // Return null if no matching asset is found
    return null;
  }
}
