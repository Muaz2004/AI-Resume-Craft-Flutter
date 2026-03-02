import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  late pw.Font _regularFont;
  late pw.Font _boldFont;
  bool _fontsLoaded = false;

  PdfService();

  /// Explicit async initialization
  Future<void> initFonts() async {
    print('[PDF] Initializing fonts...');
    try {
      final regularData =
          await rootBundle.load('lib/assets/fonts/Roboto-Regular.ttf');

      final boldData =
          await rootBundle.load('lib/assets/fonts/Roboto-Bold.ttf');
    

      _regularFont = pw.Font.ttf(regularData);
      _boldFont = pw.Font.ttf(boldData);

      _fontsLoaded = true;

    } catch (e, st) {
      throw Exception('Failed to load fonts: $e');
    }
  }

  Future<Uint8List> generateResumePdf({
    required Map<String, dynamic> data,
  }) async {
    if (!_fontsLoaded) {
      throw Exception('Fonts not initialized');
    }

   
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data['fullName'] ?? '',
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Email: ${data['email'] ?? ''}',
                  style: pw.TextStyle(font: _regularFont, fontSize: 16)),
              pw.Text('Phone: ${data['phone'] ?? ''}',
                  style: pw.TextStyle(font: _regularFont, fontSize: 16)),
              pw.Text('Address: ${data['address'] ?? ''}',
                  style: pw.TextStyle(font: _regularFont, fontSize: 16)),
              pw.SizedBox(height: 16),
              pw.Text('Education',
                  style: pw.TextStyle(font: _boldFont, fontSize: 18)),
              ...(data['education'] as List<dynamic>? ?? []).map(
                (edu) => pw.Text("• ${edu['details']}",
                    style: pw.TextStyle(font: _regularFont, fontSize: 14)),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Experience',
                  style: pw.TextStyle(font: _boldFont, fontSize: 18)),
              ...(data['experience'] as List<dynamic>? ?? []).map(
                (exp) => pw.Text("• ${exp['details']}",
                    style: pw.TextStyle(font: _regularFont, fontSize: 14)),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Skills',
                  style: pw.TextStyle(font: _boldFont, fontSize: 18)),
              pw.Text(
                  (data['skills'] as List<dynamic>?)?.join(', ') ?? '',
                  style: pw.TextStyle(font: _regularFont, fontSize: 14)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> previewPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  Future<void> sharePdf(Uint8List pdfBytes) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: 'resume.pdf');
  }
}