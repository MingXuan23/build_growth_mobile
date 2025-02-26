import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:http/http.dart' as http;

const prefix_url = 'api/gpt';

class GptRepo {

  
  static Stream<String> fastResponse(String prompt,
      {List<Map<String, dynamic>>? chat_history}) async* {
    if (chat_history?.isEmpty ?? true) {
      chat_history = null;
    }

    var request = http.Request(
      'POST',
      Uri.parse('$HOST_URL/$prefix_url/fast-response'),
    );

    var information =
        await UserPrivacy.getUserSummary(UserToken.user_code ?? '');
    var tone = information['tone'];
    information.remove('tone');
    request.headers['Content-Type'] = 'application/json';
    request.headers['Application-Id'] = appId;
    request.headers['Authorization'] = 'Bearer ${UserToken.remember_token}';

    var contentList =
        jsonEncode(ContentBloc.content_list.map((e) => e.toGPTMap()).toList());
    request.body = json.encode({
      "prompt": prompt,
      "estimate_word": -2,
      "information": information,
      "tone": tone,
      "chat_history": chat_history,
      "use_content": UserPrivacy.pushContent,
      "contentList": contentList
    });

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        String buffer = '';
        await for (var chunk in response.stream.transform(utf8.decoder)) {
          if (chunk.isNotEmpty) {
            yield chunk;
          }
          //   buffer += chunk;
          //   var parts = buffer.split('\n');

          //   for (var i = 0; i < parts.length - 1; i++) {
          //     if (parts[i].trim().isNotEmpty) {
          //       try {
          //         //var jsonData = json.decode(parts[i]);
          //         //var content = jsonData['message']['content'];
          //         yield parts[i];
          //       } catch (e) {
          //         print('Error parsing chunk: $e');
          //       }
          //     }
          //   }
          //   buffer = parts.last;
          //    print(buffer);
          // }
          // if (buffer.isNotEmpty) {
          //   try {
          //     yield buffer;
          //   } catch (e) {
          //     print('Error parsing final buffer: $e');
          //   }
        }
      } else {
        yield "Oops!😅 Connection went bye-bye!😿, but I'm buzzing around to fix it!";
      }
    } catch (e) {
      yield "Oops😅! Connection went bye-bye!😿, but I'm buzzing around to fix it!";

      print('Error fetching response: $e');
    }
  }

  static Stream<String> quickResponse(String prompt,
      {List<Map<String, dynamic>>? chat_history,
      int estimateWords = -2}) async* {
    if (chat_history?.isEmpty ?? true) {
      chat_history = null;
    }

    // var final_prompt = '';
    // if (estimateWords == -1) {
    //   final_prompt = '${prompt}. [Response as short as possible.]';
    // } else if (estimateWords == -2) {
    //   final_prompt =
    //       '${prompt}. [If related to financial domain or content, response within 200 words. If not related to the financial domain or unrealistic question, response in 30 words]';
    // } else {
    //   final_prompt = '${prompt}. [Response in ${estimateWords} words.]';
    // }

    // Fetch user information
    var userInfo = await UserPrivacy.getUserSummary(UserToken.user_code ?? '');
    var tone = userInfo['tone'];
    userInfo.remove('tone');

    var contentList =
        jsonEncode(ContentBloc.content_list.map((e) => e.toGPTMap()).toList());

    var suggest_expense = userInfo['cash_flow'];
    suggest_expense =
        suggest_expense == null ? 30 : (suggest_expense * 0.01).clamp(15, 50);

    final variables = {
      'user_info': jsonEncode(userInfo),
      'suggest_expense': suggest_expense,
      'content_list': contentList.isNotEmpty
          ? contentList
          : "You may suggest the user explore the 'Content' section for self-investment opportunities.",
      'tone': tone ?? '',
      'estimate_word': 180,
      'advise_list': MessageBloc.advice_list
    };

    var system_content = "You need to reply 'I am ready.' only";
    if (prompt != 'Initialising xBUG Ai... ') {
      system_content = generateSystemInstruction(
          protocol: THINKING_PROTOCOL, variables: variables);
    }

    List<Map<String, dynamic>> messages = [
      {
        'role': 'system',
        'content': system_content
        // 'content': 'Your name is xBUG Ai, an experienced financial advisor in the "Build Growth" Mobile App, '
        //     '${(prompt == 'Initialising xBUG Ai... ') ? 'When user said "Initialsing xBUG Ai...", you need to said "I am ready".' : 'Remember give simple greeting before response.'}'
        //     'You must suggest the advice based on the user\'s financial situation and provides practical solutions to their financial issues. '
        //     'You use RM (Ringgit Malaysia) as the main currency and respond in English. '
        //     'If the user asks for financial advice, ${tone ?? ''}. '
        //     'Your advice must based on user\'s assets and debts values and give budget plan with precise amount.'
        //     'The app has two additional sections: "Financial" and "Content." '
        //     'The average daily expenses (excluding debt and bills) should be controlled within RM$suggest_expense}'
        //     'You have read and understood the user\'s financial information from the "Financial Section": ${jsonEncode(userInfo)}.'
        //     'If necessary, suggest which expense should be reduce and which kind of asset or income should focus.'
        //     '${contentList.isNotEmpty ? " You may suggest courses and events from the 'Content' section to increase income: $contentList." : " You may suggest the user explore the 'Content' section for self-investment opportunities."}'
      },
    ];

    if (chat_history != null) {
      messages.addAll(chat_history);
    }

    messages.add({'role': 'user', 'content': '[User Question]: $prompt'});

    final requestBody = {
      'messages': messages,
      'model': '@cf/meta/llama-3.3-70b-instruct-fp8-fast',
      'stream': true,
      'temperature': 0.5,
    };

    try {
      // Create a request object instead of using http.post
      var url = GPT_ALTERNATIVE_URL;
      var token = GPT_ALTERNATIVE_TOKEN;

      Random rand = Random(DateTime.now().millisecond * DateTime.now().hour);
      int value = rand.nextInt(7);
      if (value % 4 == 1) {
        url = GPT_ALTERNATIVE_URL2;
        token = GPT_ALTERNATIVE_TOKEN2;
      } else if (value % 4 == 2) {
        url = GPT_ALTERNATIVE_URL3;
        token = GPT_ALTERNATIVE_TOKEN3;
      } else if (value % 4 == 3) {
        url = GPT_ALTERNATIVE_URL4;
        token = GPT_ALTERNATIVE_TOKEN4;
      }

      final request = http.Request('POST', Uri.parse(url));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.body = jsonEncode(requestBody);

      // Send the request and get the stream
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        String buffer = '';
        await for (var chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          buffer += chunk;

          // Split by newlines and process each line
          var lines = buffer.split('\n');

          // Process all complete lines
          for (var i = 0; i < lines.length - 1; i++) {
            var line = lines[i].trim();
            if (line.isNotEmpty) {
              try {
                // Remove "data: " prefix if present
                if (line.startsWith('data: ')) {
                  line = line.substring(5);
                }

                if (line.contains('[DONE]')) continue;

                final Map<String, dynamic> jsonData = jsonDecode(line);
                if (jsonData['response'] != null) {
                  yield jsonData['response'];
                }
              } catch (e) {
                print('Error parsing line: $e');
              }
            }
          }

          // Keep the last incomplete line in the buffer
          buffer = lines.last;
        }

        // Process any remaining data in buffer
        if (buffer.isNotEmpty) {
          try {
            if (buffer.startsWith('data: ')) {
              buffer = buffer.substring(5);
            }
            if (buffer != '[DONE]') {
              final Map<String, dynamic> jsonData = jsonDecode(buffer);
              if (jsonData['response'] != null) {
                yield jsonData['response'];
              }
            }
          } catch (e) {
            print('Error parsing final buffer: $e');
          }
        }
      } else {
        yield 'Error: API returned status code ${streamedResponse.statusCode}';
      }
    } catch (e) {
      yield 'Error: Failed to connect to the server. Details: $e';
    }
  }

  static Future<String?> getFinancialAdvice() async {
    try {
      if (!UserPrivacy.useGPT) {
        return null;
      }

      var request = await http.get(
        headers: {
          'Content-Type': 'application/json',
          'Application-Id': appId,
          'Authorization': 'Bearer ${UserToken.remember_token}'
        },
        Uri.parse('$HOST_URL/$prefix_url/get-financial-advice'),
      );

      if (request.statusCode != 200) {
        return null;
      }

      return request.body;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> slowResponse(String prompt, int tokens) async {
    try {
      if (!UserPrivacy.useGPT) {
        return null;
      }

      var information =
          await UserPrivacy.getUserSummary(UserToken.user_code ?? '');
      var tone = information['tone'];
      information.remove('tone');
      var request = await http.post(
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "prompt": prompt,
          "estimate_word": tokens,
          "information": information,
          "tone": tone
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
    String url = "$HOST_URL/api/gpt/load";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Application-Id': appId},
      );

      return (response.statusCode == 200);
    } catch (e) {
      return false;
    }
  }

  static String generateSystemInstruction({
    required String protocol,
    required Map<String, dynamic> variables,
  }) {
    String updatedProtocol = protocol;

    variables.forEach((key, value) {
      final placeholder = '<variable_$key>';
      updatedProtocol =
          updatedProtocol.replaceAll(placeholder, value.toString());
    });

    return updatedProtocol;
  }
}
