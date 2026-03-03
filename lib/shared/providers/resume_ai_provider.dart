import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/services/ai/resume_ai_service.dart';

final resumeAiServiceProvider = Provider((ref) {
  return ResumeAiService();
});

final resumeAiProvider =
    AsyncNotifierProvider<ResumeAiNotifier, String?>(() {
  return ResumeAiNotifier();
});

class ResumeAiNotifier extends AsyncNotifier<String?> {
  late final ResumeAiService _service;

  @override
  Future<String?> build() async {
    _service = ref.read(resumeAiServiceProvider);
    return null;
  }

  Future<void> enhance(String input) async {
    try {
      state = const AsyncValue.loading();

      final result = await _service.enhanceExperience(input);

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}