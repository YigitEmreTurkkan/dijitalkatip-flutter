import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:dk/models/document.dart';
import 'package:dk/services/pdf_generator.dart';

class DocumentScreen extends StatelessWidget {
  final Document? document;

  const DocumentScreen({super.key, this.document});

  @override
  Widget build(BuildContext context) {
    final doc = document;

    if (doc == null || doc.id.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doc.header != null)
              Center(
                child: Text(
                  doc.header!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            _buildSection('DAVACI:', doc.plaintiffDetails),
            _buildSection('DAVALI:', doc.defendantDetails),
            _buildSection('KONU:', doc.subject),
            _buildSection('AÇIKLAMALAR:', doc.incidentNarrative, isJustified: true),
            _buildSection('HUKUKİ SEBEPLER VE DELİLLER:', doc.legalGrounds),
            _buildSection('DELİLLER:', doc.evidenceList),
            _buildSection('SONUÇ VE İSTEM:', doc.conclusionRequest, isJustified: true),
            _buildSignatureSection(),
            if (doc.conclusionRequest?.contains('DİKKAT') ?? false)
              _buildWarningBox(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PdfGenerator.generatePdf(doc),
        label: const Text('PDF İndir'),
        icon: const Icon(LucideIcons.download),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.fileText, size: 64, color: Color(0xFFD1D5DB)), // slate-300
          SizedBox(height: 16),
          Text(
            'Dilekçe oluşturmak için sohbete başlayın',
            style: TextStyle(color: Color(0xFF6B7280)), // slate-500
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String? content, {bool isJustified = false}) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              content,
              textAlign: isJustified ? TextAlign.justify : TextAlign.start,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Saygılarımla,'),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.only(top: 4, bottom: 4, left: 24, right: 24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFCBD5E1))), // slate-300
              ),
              child: const Text('İmza'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8), // yellow-50
        border: const Border(left: BorderSide(color: Color(0xFFFACC15), width: 4)), // yellow-400
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DİKKAT:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF854D0E), // yellow-800
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bu belge bir taslak niteliğindedir ve avukat tavsiyesi yerine geçmez. Hukuki hak kaybı yaşamamak için bir avukata danışmanız ve metni somut olaya göre düzenlemeniz önerilir.',
            style: TextStyle(
              color: Color(0xFF854D0E), // yellow-700
            ),
          ),
        ],
      ),
    );
  }
}
