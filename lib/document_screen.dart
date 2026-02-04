import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:dk/models/document.dart';
import 'package:dk/services/pdf_generator.dart';
import 'package:dk/theme.dart';

class DocumentScreen extends StatelessWidget {
  final Document? document;

  const DocumentScreen({super.key, this.document});

  @override
  Widget build(BuildContext context) {
    final doc = document;
    final theme = Theme.of(context);

    if (doc == null || doc.id.isEmpty) {
      return _buildEmptyState(context);
    }

    return Scaffold(
      backgroundColor: surfaceColor, // Temiz beyaz arka plan
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: SizedBox(
            width: 800, // Max width for readability on wide screens
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBanner(theme),
                const SizedBox(height: 24),
                if (doc.header != null)
                  Center(
                    child: Text(
                      doc.header!,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32),
                _buildSection(theme, 'DAVACI', doc.plaintiffDetails),
                _buildSection(theme, 'DAVALI', doc.defendantDetails),
                const SizedBox(height: 16),
                _buildSection(theme, 'KONU', doc.subject, isBold: false),
                const SizedBox(height: 24),
                _buildSection(theme, 'AÇIKLAMALAR', doc.incidentNarrative, isJustified: true),
                _buildSection(theme, 'HUKUKİ SEBEPLER VE DELİLLER:', doc.legalGrounds),
                _buildSection(theme, 'DELİLLER', doc.evidenceList),
                const SizedBox(height: 24),
                _buildSection(theme, 'SONUÇ VE İSTEM', doc.conclusionRequest, isJustified: true),
                _buildSignatureSection(theme),
                if (doc.conclusionRequest?.contains('DİKKAT') ?? false)
                  _buildWarningBox(theme),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PdfGenerator.generatePdf(doc),
        label: const Text('PDF İndir'),
        icon: const Icon(LucideIcons.download, size: 20),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.fileText, size: 64, color: theme.colorScheme.onBackground.withOpacity(0.2)),
          const SizedBox(height: 24),
          Text(
            '2. Adım: Dilekçeniz burada görünecek',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Önce "Sohbet" sekmesinde bana olayı anlatın.\n'
            'Sonra buraya geri geldiğinizde, metin otomatik olarak doldurulmuş olacak.\n'
            'Metin oluştuğunda sağ alttaki "PDF İndir" butonuyla PDF çıkarabilirsiniz.',
            style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String? content, {bool isJustified = false, bool isBold = true}) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: isJustified ? TextAlign.justify : TextAlign.start,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bu sayfada, sohbet ekranında verdiğiniz bilgilerle otomatik olarak oluşturulan dilekçenin güncel halini görüyorsunuz.\n'
              'Metin üzerinde değişiklik yaptıkça bu sayfayı yenileyerek sonucu görebilir, sağ alttaki "PDF İndir" butonuyla PDF oluşturabilirsiniz.',
              style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Saygılarımla,', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 64),
            Text('Davacı Vekili', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
             Text('Av. [Adınız Soyadınız]', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('(e-imzalıdır)', style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor)),

          ],
        ),
      ),
    );
  }

  Widget _buildWarningBox(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, color: Colors.yellow.shade800, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu belge bir taslak niteliğindedir ve avukat tavsiyesi yerine geçmez. Hukuki hak kaybı yaşamamak için bir avukata danışmanız ve metni somut olaya göre düzenlemeniz önerilir.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.yellow.shade900, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
