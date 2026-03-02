import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/services/pdf/pdf_service.dart';



final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});