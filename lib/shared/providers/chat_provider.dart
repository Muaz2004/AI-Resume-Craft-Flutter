import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/features/chat/data/chat_message_model.dart';
import 'package:resume_ai/services/ai/resume_ai_service.dart';


final chatAiServiceProvider = Provider((ref) {
  return ResumeAiService();
});


class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  bool isLoading = false;

  ChatNotifier(this.ref) : super([]);

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    
    state = [
      ...state,
      ChatMessage(
        content: content,
        sender: "user",
        timestamp: DateTime.now(),
      )
    ];

    
    isLoading = true;
    try {
    
      final aiService = ref.read(chatAiServiceProvider);
      final response = await aiService.enhanceText(content, ResumeSection.experience);

      
      state = [
        ...state,
        ChatMessage(
          content: response,
          sender: "ai",
          timestamp: DateTime.now(),
        )
      ];
    } catch (e) {
      
      state = [
        ...state,
        ChatMessage(
          content: "AI failed to respond: $e",
          sender: "ai",
          timestamp: DateTime.now(),
        )
      ];
    } finally {
      isLoading = false;
    }
  }

  void clearChat() {
    state = [];
  }
}


final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(ref),
);