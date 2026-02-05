import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' show PdfGoogleFonts;
import 'package:printing/printing.dart';
import '../models/document.dart' as model;

class PdfGenerator {
  static Future<void> generatePdf(model.Document doc) async {
    // Google fontları (Türkçe karakter uyumlu) yükle
    final baseFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (doc.header != null)
                pw.Center(
                  child: pw.Text(
                    doc.header!,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              pw.SizedBox(height: 24),
              _buildSection('DAVACI:', doc.plaintiffDetails),
              _buildSection('DAVALI:', doc.defendantDetails),
              _buildSection('KONU:', doc.subject),
              _buildSection('AÇIKLAMALAR:', doc.incidentNarrative, isJustified: true),
              _buildSection('HUKUKİ SEBEPLER VE DELİLLER:', doc.legalGrounds),
              _buildSection('DELİLLER:', doc.evidenceList),
              _buildSection('SONUÇ VE İSTEM:', doc.conclusionRequest, isJustified: true),
              _buildSignatureSection(doc),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildSection(String title, String? content, {bool isJustified = false}) {
    if (content == null || content.isEmpty) {
      return pw.SizedBox.shrink();
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 16.0),
            child: pw.Text(
              content,
              textAlign: isJustified ? pw.TextAlign.justify : pw.TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureSection(model.Document doc) {
    final creatorName = _getCreatorName(doc);
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Padding(
        padding: const pw.EdgeInsets.only(top: 32.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Saygılarımla,'),
            pw.SizedBox(height: 48),
            pw.Text('Oluşturan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(creatorName),
          ],
        ),
      ),
    );
  }

  static String _getCreatorName(model.Document doc) {
    final raw = doc.plaintiffDetails?.trim();
    if (raw == null || raw.isEmpty) {
      return '[Adınız Soyadınız]';
    }
    final firstLine = raw.split('\n').first.trim();
    if (firstLine.isEmpty) {
      return '[Adınız Soyadınız]';
    }
    return firstLine;
  }
}
