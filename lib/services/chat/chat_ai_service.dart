import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatAiService {
  final String _endpoint = "https://api.groq.com/openai/v1/chat/completions";

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  Future<String> sendMessage(String input) async {
    if (_apiKey.isEmpty) {
      throw Exception("API Key not found in .env");
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "llama-3.3-70b-versatile",
        "messages": [
          {
            "role": "system",
            "content": """
You are a professional career assistant.

Provide clear, detailed, and structured explanations.
When appropriate:
- do not make it long just since that makes user lose interest, but make it detailed enough to be helpful.
- Break answers into short paragraphs.
- Use bullet points for clarity.
- Give practical examples.

Keep the tone professional and supportive.
Do not mention that you are an AI.
Return only the response text.
"""
          },
          {
            "role": "user",
            "content": input
          }
        ],
        "temperature": 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"].trim();
    } else {
      throw Exception(
          "Groq API error: ${response.statusCode} - ${response.body}");
    }
  }
}