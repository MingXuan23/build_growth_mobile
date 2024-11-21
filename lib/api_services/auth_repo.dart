import 'dart:convert';
import 'package:build_growth_mobile/env.dart';
import 'package:http/http.dart' as http;

class AuthRepo {
  // The base URL of your API (adjust if necessary)

  static String url_prefix = 'api/auth';
  // Method to register a user
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> requestBody) async {
    // Prepare the data for registration

    try {
      // Make the POST request to the register API
      final response = await http.post(
        Uri.parse(
            '$HOST_URL/$url_prefix/register'), // Adjust the URL as necessary
        headers: {
          'Content-Type': 'application/json',
        },
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
    };

    try {
      final response = await http.post(
        Uri.parse('$HOST_URL/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Login successful',
          'data': responseData['data'], // Return user data or token
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

  static Future<int> sendVerificationCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$HOST_URL/$url_prefix/verify/$email'),
        headers: {
          'Content-Type': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode;
    } catch (e) {
      return 404;
    }
  }
}
