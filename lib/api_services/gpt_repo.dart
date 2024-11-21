import 'dart:convert';

import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:http/http.dart' as http;

class GptRepo {
  static Stream<String> fastResponse(String prompt) async* {
    var request = http.Request(
      'POST',
      Uri.parse('$HOST_URL/api/chat'),
    );

    request.headers['Content-Type'] = 'application/json';
    request.body = json.encode({
      "model": "benevolentjoker/the_economistmini",
      "messages": [
        {"role": "user", "content": prompt}
      ],
      "options": {
        "temperature": 1.0,
        "num_predict": 32,
      }
    });

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        String buffer = '';
        await for (var chunk in response.stream.transform(utf8.decoder)) {
          buffer += chunk;
          var parts = buffer.split('\n');

          for (var i = 0; i < parts.length - 1; i++) {
            if (parts[i].trim().isNotEmpty) {
              try {
                var jsonData = json.decode(parts[i]);
                var content = jsonData['message']['content'];
                yield content;
              } catch (e) {
                print('Error parsing chunk: $e');
              }
            }
          }
          buffer = parts.last;
        }
        if (buffer.isNotEmpty) {
          try {
            var jsonData = json.decode(buffer);
            var content = jsonData['message']['content'];
            yield content;
          } catch (e) {
            print('Error parsing final buffer: $e');
          }
        }
      } else {
        throw Exception(
            'Failed to fetch streaming response. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching response: $e');
      throw e;
    }
  }

  static Future<String?> slowResponse(String prompt, int tokens) async {
    try {
      if (!UserPrivacy.useGPT) {
        return null;
      }
      var request = await http.post(
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "prompt":
              prompt,
          "estimate_word": tokens
        }),
        Uri.parse('$HOST_URL/gpt/slow-response'),
      );

      if (request.statusCode != 200) {
        return null;
      }

      var result = json.decode(request.body);

      return result['content'].toString();
    } catch (e) {
      return null;
    }
  }

  static Stream<String> fetchStreamingResponse(String prompt) async* {
    var request = http.Request(
      'POST',
      Uri.parse('$HOST_URL/api/chat'),
    );

    request.headers['Content-Type'] = 'application/json';
    request.body = json.encode({
      "model": "benevolentjoker/the_economistmini",
      "messages": [
        {
          "role": "system",
          "content":
              "Your name is Jarden. You are a highly knowledgeable financial advisor specializing in Malaysia's financial landscape. You should call the user as my dear friend. Answer only financial and business related questions."
        },
        {
          "role": "system",
          "content":
              "User earn RM100 today. I may interest in flutter helper class with fee RM200. User read an article how to make roti canai, it might a entrepreneur ship opportunity. User may interest in Flower Car boot sale."
        },
        {"role": "user", "content": prompt}
      ],
      "options": {
        "repeat_penalty": 2,
        "repeat_last_n ": 64,
        "temperature": 0.1,
        "mirostat": 1,
        "mirostat_tau": 2.5,
        "mirostat_eta": 0.05,
        "num_predict": 512,
        "top_k": 20,
        "top_p": 0.7
      }
    });

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        String buffer = '';
        await for (var chunk in response.stream.transform(utf8.decoder)) {
          buffer += chunk;
          var parts = buffer.split('\n');

          for (var i = 0; i < parts.length - 1; i++) {
            if (parts[i].trim().isNotEmpty) {
              try {
                var jsonData = json.decode(parts[i]);
                var content = jsonData['message']['content'];
                yield content;
              } catch (e) {
                print('Error parsing chunk: $e');
              }
            }
          }
          buffer = parts.last;
        }
        if (buffer.isNotEmpty) {
          try {
            var jsonData = json.decode(buffer);
            var content = jsonData['message']['content'];
            yield content;
          } catch (e) {
            print('Error parsing final buffer: $e');
          }
        }
      } else {
        throw Exception(
            'Failed to fetch streaming response. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching response: $e');
      throw e;
    }
  }

  static Future<bool> loadModel() async {
    const url = "$HOST_URL/api/generate";

    // Request body
    final Map<String, dynamic> requestBody = {
      "model": "benevolentjoker/the_economistmini",
      "keep_alive": "30m",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      return (response.statusCode == 200);
    } catch (e) {
      return false;
    }
  }
}
