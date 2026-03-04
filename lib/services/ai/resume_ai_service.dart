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
        "model": "llama-3.3-70b-versatile",
       "messages": [
  {
    "role": "system",
    "content": """
You are a professional resume writer.

Rewrite the user's experience to be concise, achievement-oriented, and results-driven.
Use strong action verbs.
Quantify impact when possible.
Make it ATS-friendly.

Do NOT include explanations.
Do NOT say "Here is the revised version".
Do NOT provide alternatives.
Return ONLY the final improved experience text as plain text.
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