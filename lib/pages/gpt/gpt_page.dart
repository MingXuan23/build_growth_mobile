import 'dart:convert';
import 'dart:async';
import 'package:build_growth_mobile/api_services/gpt_repo.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


//llm = Ollama(model="phi:latest", base_url="http://ollama-container:11434", verbose=True)

//initial_prompt='''You are a highly knowledgeable financial advisor specializing in Indian finance. You have a deep understanding of various financial domains, including personal finance, investments, taxation, real estate, and retirement planning. You are well-versed in Indian financial regulations and policies. Your goal is to provide accurate, insightful, and personalized financial advice to users based on their specific questions and needs.
class GptPage extends StatefulWidget {
  const GptPage({super.key});

  @override
  State<GptPage> createState() => _GptPageState();
}

class _GptPageState extends State<GptPage> {
  String _streamingText = "";
  final TextEditingController _controller = TextEditingController();
  StreamSubscription? _subscription;

  bool _isLoading = false;

  void _startFetching(String prompt) async {
    try {
      await for (var content in GptRepo.fetchStreamingResponse(prompt)) {
        setState(() {
          _streamingText += content;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPT Chat'),
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(_streamingText),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _startFetching(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
