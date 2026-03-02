import 'dart:typed_data'; 
import 'package:pdf/widgets.dart' as pw; 
import 'package:printing/printing.dart'; 

class PdfService {
  
  /// Returns the PDF bytes
  Future<Uint8List> generateResumePdf({
    required Map<String, dynamic> data, 
  }) async {
    try {
      final pdf = pw.Document(); 

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(data['fullName'] ?? '', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Email: ${data['email'] ?? ''}', style: pw.TextStyle(fontSize: 16)),
                pw.Text('Phone: ${data['phone'] ?? ''}', style: pw.TextStyle(fontSize: 16)),
                pw.Text('Address: ${data['address'] ?? ''}', style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 16),
                pw.Text('Education', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ...(data['education'] as List<dynamic>? ?? []).map(
                  (edu) => pw.Text("• ${edu['details']}", style: pw.TextStyle(fontSize: 14)),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Experience', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ...(data['experience'] as List<dynamic>? ?? []).map(
                  (exp) => pw.Text("• ${exp['details']}", style: pw.TextStyle(fontSize: 14)),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Skills', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text((data['skills'] as List<dynamic>?)?.join(', ') ?? '', style: pw.TextStyle(fontSize: 14)),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save(); 
      return bytes; 
    } catch (e) {
      throw Exception('Failed to generate PDF: $e'); 
    }
  }

  /// Preview PDF before download/share
  Future<void> previewPdf(Uint8List pdfBytes) async { 
    try {
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
    } catch (e) {
      throw Exception('Failed to preview PDF: $e');
    }
  }

  /// Share generated PDF
  Future<void> sharePdf(Uint8List pdfBytes) async { 
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: 'resume.pdf');
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }
}