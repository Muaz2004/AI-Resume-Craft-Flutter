import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/services/ai/resume_ai_service.dart';

final resumeAiServiceProvider = Provider((ref) {
  return ResumeAiService();
});

final resumeAiProvider =
    AsyncNotifierProviderFamily<ResumeAiNotifier, String?, ResumeSection>(
  ResumeAiNotifier.new,
);

class ResumeAiNotifier extends FamilyAsyncNotifier<String?, ResumeSection> {
  late final ResumeAiService _service;

  @override
  Future<String?> build(ResumeSection section) async {
    _service = ref.read(resumeAiServiceProvider);
    return null;
  }

  Future<void> enhance(String input, ResumeSection section) async {
    try {
      state = const AsyncValue.loading();

      final result = await _service.enhanceText(input, section);

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}