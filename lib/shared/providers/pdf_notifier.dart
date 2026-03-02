import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/services/pdf/pdf_service.dart';
import 'pdf_provider.dart';

final pdfNotifierProvider =
    AsyncNotifierProvider<PdfNotifier, String?>(() => PdfNotifier());

class PdfNotifier extends AsyncNotifier<String?> {
  late final PdfService _pdfService;

  @override
  Future<String?> build() async {
    _pdfService = ref.read(pdfServiceProvider);
    return null; 
  }

  Future<void> generatePdf(Map<String, dynamic> data) async {
    try {
      state = const AsyncValue.loading();
      final filePath = await _pdfService.generateResumePdf(data: data);
      state = AsyncValue.data(filePath);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

 
  Future<void> previewPdf() async {
    if (state.value != null) {
      await _pdfService.previewPdf(state.value!);
    }
  }

  
  Future<void> sharePdf() async {
    if (state.value != null) {
      await _pdfService.sharePdf(state.value!);
    }
  }
}