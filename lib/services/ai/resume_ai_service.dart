import 'dart:convert';
import 'package:http/http.dart' as http;

class ResumeAiService {
  final String _apiKey = ""; 
  final String _endpoint =
      "https://api.groq.com/openai/v1/chat/completions";

  Future<String> enhanceExperience(String input) async {
    try {
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
                  "You are a professional resume writer. Improve the following experience professionally."
            },
            {
              "role": "user",
              "content": input
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"];
      } else {
        throw Exception("AI request failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to enhance experience: $e");
    }
  }
}