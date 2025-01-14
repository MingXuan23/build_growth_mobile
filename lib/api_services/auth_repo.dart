import 'dart:convert';
import 'dart:io';
import 'package:build_growth_mobile/bloc/gold_leaf_bloc/gold_leaf_bloc.dart';
import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/models/golden_leaf.dart';
import 'package:build_growth_mobile/models/user_info.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:http/http.dart' as http;

class AuthRepo {
  // The base URL of your API (adjust if necessary)

  static String url_prefix = 'api/auth';

  static Future<bool> validateEnvironment() async {
    try {
      Uri uri = Uri.parse(HOST_URL);

      final result = await InternetAddress.lookup(uri.host);

      if (uri.hasPort) {
        final socket = await Socket.connect(uri.host, uri.port,
            timeout: Duration(milliseconds: 500));
        socket.destroy(); // Close the socket after testing
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Method to register a user
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> requestBody) async {
    // Prepare the data for registration

    try {
      // Make the POST request to the register API
      final response = await http.post(
        Uri.parse(
            '$HOST_URL/$url_prefix/register'), // Adjust the URL as necessary
        headers: {'Content-Type': 'application/json', 'Application-Id': appId},
        body: jsonEncode(requestBody),
      );

      // Handle different response codes
      if (response.statusCode == 201) {
        // If the registration was successful
        final responseData = jsonDecode(response.body);
        return {
          'status': response.statusCode,
          //'message': responseData['message'],
        };
      } else if (response.statusCode == 403) {
        // If there was an issue with the request (e.g., email already in use)
        final responseData = jsonDecode(response.body);
        return {
          'status': response.statusCode,
          'message': responseData['message'],
        };
      } else if (response.statusCode == 400) {
        // If there was an issue with the request (e.g., email already in use)
        final responseData = jsonDecode(response.body);
        return {
          'status': response.statusCode,
          'message': responseData['message'],
        };
      } else {
        // Handle other errors
        return {
          'status': 500,
          'message': response.reasonPhrase,
        };
      }
    } catch (error) {
      // Handle network or other errors
      return {
        'status': 500,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  static Future<List<String>> getStateList() async {
    try {
      final response = await http.get(
        Uri.parse('$HOST_URL/$url_prefix/get-states'),
        headers: {'Content-Type': 'application/json', 'Application-Id': appId},
      ).timeout(
        const Duration(seconds: 5), // Set timeout duration
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return (data as List).map((e) => e['name'].toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Method for login (similar to registration)
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
      'device_token': UserToken.device_token
    };

    try {
      final response = await http.post(
        Uri.parse('$HOST_URL/$url_prefix/login'),
        headers: {'Content-Type': 'application/json', 'Application-Id': appId},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        UserToken.initialise(
            email: responseData['email'],
            user_code: responseData['token'],
            remember_token: responseData['rememberToken']);
        await UserToken.save();
        return {
          'success': true,
          'message': 'Login successful',
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'],
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  static Future<(bool, String)> validateSession(
      String remember_token, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$HOST_URL/$url_prefix/validate-session'),
        headers: {'Content-Type': 'application/json', 'Application-Id': appId},
        body: jsonEncode({'rememberToken': remember_token, 'email': email}),
      );

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        UserToken.remember_token = res['rememberToken'];
        UserToken.save();
        return (true, '');
      } else {
        var res = jsonDecode(response.body);
        UserToken.remember_token = null;
        UserToken.save();

        return (false, res['message'].toString());
      }
    } catch (e) {
      return (false, e.toString());
    }
  }

  static Future<(bool, String)> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$HOST_URL/$url_prefix/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Application-Id': appId,
          'Authorization': 'Bearer ${UserToken.remember_token}'
        },
        body: jsonEncode(
            {'oldPassword': oldPassword, 'newPassword': newPassword}),
      );

      var res = jsonDecode(response.body);

      return ((response.statusCode == 200), res['message'].toString());
    } catch (e) {
      return (false, e.toString());
    }
  }

  static Future<String> forgetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$HOST_URL/$url_prefix/forget-password'),
        headers: {'Content-Type': 'application/json', 'Application-Id': appId},
        body: jsonEncode({'email': email}),
      );

      var res = jsonDecode(response.body);
      UserToken.remember_token = null;
      UserToken.save();

      return res['message'].toString();
    } catch (e) {
      return e.toString();
    }
  }

  static Future<int> sendVerificationCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$HOST_URL/$url_prefix/verify/$email'),
        headers: {'Content-Type': 'application/json', 'Application-Id': appId},
        body: jsonEncode({'code': code}),
      );

      return response.statusCode;
    } catch (e) {
      return 404;
    }
  }

  static Future<int> resendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$HOST_URL/$url_prefix/resend/$email'),
        headers: {'Content-Type': 'application/json', 'Application-Id': appId},
      );

      return response.statusCode;
    } catch (e) {
      return 404;
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.post(
        Uri.parse('$HOST_URL/$url_prefix/get-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Application-Id': appId,
          'Authorization': 'Bearer ${UserToken.remember_token}'
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['user_privacy'] != null) {
          UserPrivacy.fromMap((data['user_privacy']['detail']) is String
              ? jsonDecode(data['user_privacy']['detail'])
              : (data['user_privacy']['detail']));
        }

        return {
          'user_info': UserInfo(
            address: data['address'] ?? 'xxx',
            name: data['name'] ?? 'xxx',
            state: data['state'] ?? 'xxx',
            email: data['email'] ?? 'xxx@xxx.xx',
            telno: data['telno'] ?? 'xxx',
          ),
          'success': true
        };
      }
      return {"success": false};
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<int> updateProfile(Map<String, dynamic> body) async {
    try {
      final response =
          await http.post(Uri.parse('$HOST_URL/$url_prefix/update-profile'),
              headers: {
                'Content-Type': 'application/json',
                'Application-Id': appId,
                'Authorization': 'Bearer ${UserToken.remember_token}'
              },
              body: jsonEncode(body));

      return response.statusCode;
    } catch (e) {
      return 500;
    }
  }

  static Future<bool> updateUserPrivacy(String detail) async {
    try {
      final response =
          await http.post(Uri.parse('$HOST_URL/$url_prefix/update-privacy'),
              headers: {
                'Content-Type': 'application/json',
                'Application-Id': appId,
                'Authorization': 'Bearer ${UserToken.remember_token}'
              },
              body: jsonEncode({'user_privacy': detail}));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getLeafStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$HOST_URL/$url_prefix/get-leaf-status'),
        headers: {
          'Content-Type': 'application/json',
          'Application-Id': appId,
          'Authorization': 'Bearer ${UserToken.remember_token}'
        },
      );
      //body: jsonEncode({'user_privacy': detail}));

    if(response.statusCode ==200){
 var body = jsonDecode(response.body);

      return {'status': true, 'data': body['data']};
    }
     return {
        'status': false,
      };
      // return response.statusCode == 200;
    } catch (e) {
      return {
        'status': false,
      };
    }
  }

  static Future<String> addNewLeaf(String detail) async {
    try {
      final response =
          await http.post(Uri.parse('$HOST_URL/$url_prefix/add-new-leaf'),
              headers: {
                'Content-Type': 'application/json',
                'Application-Id': appId,
                'Authorization': 'Bearer ${UserToken.remember_token}'
              },
              body: jsonEncode({'detail': detail}));

      if (response.statusCode == 201) {
        var body = jsonDecode(response.body);
        GoldLeafBloc.leafData = body['data'];
        return 'Yey! You collected Golden Leaf today.';
      } else if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        GoldLeafBloc.leafData = body['data'];
        return ' You have collected Golden Leaf.';

      }
    
      return 'Too much Traffic. Please try again';
    } catch (e) {
      return 'Error in handling your request';
    }
  }
}
