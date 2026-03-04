import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/services/chat/chat_ai_service.dart';


class ChatMessage {
  final String content;
  final bool isUser;

  ChatMessage({required this.content, required this.isUser});
}

final chatAiServiceProvider = Provider((ref) => ChatAiService());

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref.read);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Reader _read;
  ChatNotifier(this._read) : super([]);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String input) async {
    if (input.trim().isEmpty) return;

    // Add user message immediately
    state = [...state, ChatMessage(content: input, isUser: true)];

    _isLoading = true;

    try {
      final response =
          await _read(chatAiServiceProvider).sendMessage(input);

      // Add AI response
      state = [...state, ChatMessage(content: response, isUser: false)];
    } catch (e) {
      state = [...state, ChatMessage(content: "Error: $e", isUser: false)];
    } finally {
      _isLoading = false;
    }
  }

  void clearChat() {
    state = [];
  }
}