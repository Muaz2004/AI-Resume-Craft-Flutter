import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/services/pdf/pdf_service.dart';
import 'pdf_provider.dart';
import 'dart:typed_data';

final pdfNotifierProvider =
    AsyncNotifierProvider<PdfNotifier, Uint8List?>(() => PdfNotifier()); // changed to Uint8List

class PdfNotifier extends AsyncNotifier<Uint8List?> {
  late final PdfService _pdfService;

  @override
  Future<Uint8List?> build() async {
    _pdfService = ref.read(pdfServiceProvider);
    return null; // initial state
  }

  /// Generate PDF in memory
  Future<void> generatePdf(Map<String, dynamic> data) async {
    try {
      state = const AsyncValue.loading();
      final pdfBytes = await _pdfService.generateResumePdf(data: data); // returns Uint8List
      state = AsyncValue.data(pdfBytes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Preview PDF
  Future<void> previewPdf() async {
    final pdfBytes = state.value;
    if (pdfBytes != null) {
      await _pdfService.previewPdf(pdfBytes);
    }
  }

  /// Share PDF
  Future<void> sharePdf() async {
    final pdfBytes = state.value;
    if (pdfBytes != null) {
      await _pdfService.sharePdf(pdfBytes);
    }
  }
}