import 'dart:convert';
import 'dart:io';
import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:http/http.dart' as http;

class AuthRepo {
  // The base URL of your API (adjust if necessary)

  static String url_prefix = 'api/auth';

  static Future<bool> validateEnvironment() async {
    try {
      final result = await InternetAddress.lookup(HOST_URL);
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
        headers: {'Content-Type': 'application/json', 'Application-Id': appId , 'Authorization':'Bearer ${UserToken.remember_token}'},
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
}
