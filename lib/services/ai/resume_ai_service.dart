import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ResumeSection { experience, skills, education } // AI ENHANCEMENT CHANGE

class ResumeAiService {
  final String _endpoint =
      "https://api.groq.com/openai/v1/chat/completions";

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  // UPDATED: single method for multiple sections
  Future<String> enhanceText(String input, ResumeSection section) async { // AI ENHANCEMENT CHANGE
    if (_apiKey.isEmpty) {
      throw Exception("API Key not found in .env");
    }

    String prompt = "";
    switch (section) { // AI ENHANCEMENT CHANGE
      case ResumeSection.experience:
        prompt = "Rewrite the user's experience to be concise, achievement-oriented, and results-driven. Use strong action verbs. Quantify impact when possible. Make it ATS-friendly. Do NOT include explanations, alternatives, or 'Here is the revised version'. Return ONLY the final improved experience text as plain text.";
        break;
      case ResumeSection.skills:
        prompt = "Rewrite the user's skills to be concise, professional, and optimized for ATS. Remove redundancies and make them impactful. Return ONLY the final improved skills as plain text.";
        break;
      case ResumeSection.education:
        prompt = "Rewrite the user's education section to be concise, professional, and results-oriented. Highlight achievements if possible. Return ONLY the final improved education text as plain text.";
        break;
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
          {"role": "system", "content": prompt},
          {"role": "user", "content": input}
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