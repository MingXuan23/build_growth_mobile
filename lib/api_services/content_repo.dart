import 'dart:convert';

import 'package:build_growth_mobile/bloc/content_init/content_init_bloc.dart';
import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/models/content.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ContentRepo {
  static const content_prefix = 'api/content';
  static const vector_prefix = 'api/vector';

  static Future<Map<String, dynamic>> loadContent() async {
    String url = "$HOST_URL/$content_prefix";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Application-Id': appId,
          'Authorization': 'Bearer ${UserToken.remember_token}'
        },
      );

      if (response.statusCode == 201) {
        var data = jsonDecode(response.body);

        var list = data.map((map) => Content.fromMap(map)).toList();

        return {'result': response.statusCode, 'list': list};
      } else if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        var list =
            data['contentList'].map((map) => Content.fromMap(map)).toList();
        return {
          'result': response.statusCode,
          'list': list,
          "microlearning_id": data['microlearning_id']
        };
      } else {
        return {'result': response.statusCode, 'list': []};
      }
    } catch (e) {
      return {'result': 500, 'list': []};
    }
  }

  static Future<String> saveContentTest(
      List<Content> like_list, List<Content> dislike_list) async {
    String url = "$HOST_URL/$vector_prefix/submit-vector-test";

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Application-Id': appId,
            'Authorization': 'Bearer ${UserToken.remember_token}'
          },
          body: jsonEncode({
            'like_content_ids': like_list.map((e) => e.id).toList(),
            'dislike_content_ids': dislike_list.map((e) => e.id).toList()
          }));

      var res = jsonDecode(response.body);
      return res['message'];
    } catch (e) {
      return e.toString();
    }
  }

  static Future<int> saveContentEnrollment(
      String card_id, String verification_code) async {
    String url = "$HOST_URL/$content_prefix/save-content-attendance";

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Application-Id': appId,
            'Authorization': 'Bearer ${UserToken.remember_token}'
          },
          body: jsonEncode(
              {'card_id': card_id, 'verification_code': verification_code}));

      return response.statusCode;
    } catch (e) {
      return 500;
    }
  }

  static Future<int> updateUserContent(int id, String action) async {
    String url = "$HOST_URL/$content_prefix/update-user-content";

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Application-Id': appId,
            'Authorization': 'Bearer ${UserToken.remember_token}'
          },
          body: jsonEncode({'content_id': id, 'action': action}));

      return response.statusCode;
    } catch (e) {
      return 500;
    }
  }

  static Future<List<Content>> getAttendanceHistory() async {
    String url = "$HOST_URL/$content_prefix/get-attendance-history";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Application-Id': appId,
          'Authorization': 'Bearer ${UserToken.remember_token}'
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        var list = (data['history'] as List)
            .map((map) => Content.fromMap(map))
            .toList();
        return list;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Content>> getViewContents() async {
    String url = "$HOST_URL/$content_prefix/get-clicked-content";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Application-Id': appId,
          'Authorization': 'Bearer ${UserToken.remember_token}'
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        var list = (data['clicked_list'] as List)
            .map((map) => Content.fromMap(map))
            .toList();

        return list;
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
