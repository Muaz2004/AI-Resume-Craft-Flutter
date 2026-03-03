import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResumeAiService {
  final String _endpoint =
      "https://api.groq.com/openai/v1/chat/completions";

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  Future<String> enhanceExperience(String input) async {
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
        "model": "llama3-8b-8192",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a professional resume writer. Improve the following experience professionally. Keep it concise and impactful."
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