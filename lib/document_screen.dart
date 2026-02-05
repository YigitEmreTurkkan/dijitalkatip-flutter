import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dk/models/document.dart';
import 'package:dk/services/pdf_generator.dart';
import 'package:dk/theme.dart';
import 'package:dk/state/app_state.dart';

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
                _buildSignatureSection(theme, doc),
                if (doc.conclusionRequest?.contains('DİKKAT') ?? false)
                  _buildWarningBox(theme),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'edit-doc',
            onPressed: () => _openEditDialog(context, doc),
            label: const Text('Düzenle'),
            icon: const Icon(Icons.edit, size: 20),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'pdf-doc',
            onPressed: () => PdfGenerator.generatePdf(doc),
            label: const Text('PDF İndir'),
            icon: const Icon(LucideIcons.download, size: 20),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ],
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

  Widget _buildSignatureSection(ThemeData theme, Document doc) {
    final creatorName = _getCreatorName(doc);
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Saygılarımla,', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 64),
            Text('Oluşturan', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(creatorName, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('(e-imzalıdır)', style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor)),

          ],
        ),
      ),
    );
  }

  String _getCreatorName(Document doc) {
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

  void _openEditDialog(BuildContext context, Document doc) {
    final headerController = TextEditingController(text: doc.header ?? '');
    final plaintiffController = TextEditingController(text: doc.plaintiffDetails ?? '');
    final defendantController = TextEditingController(text: doc.defendantDetails ?? '');
    final subjectController = TextEditingController(text: doc.subject ?? '');
    final narrativeController = TextEditingController(text: doc.incidentNarrative ?? '');
    final legalController = TextEditingController(text: doc.legalGrounds ?? '');
    final evidenceController = TextEditingController(text: doc.evidenceList ?? '');
    final conclusionController = TextEditingController(text: doc.conclusionRequest ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Dilekçeyi Düzenle'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEditField('Başlık', headerController, maxLines: 2),
                  _buildEditField('Davacı', plaintiffController, maxLines: 4),
                  _buildEditField('Davalı', defendantController, maxLines: 4),
                  _buildEditField('Konu', subjectController, maxLines: 3),
                  _buildEditField('Açıklamalar', narrativeController, maxLines: 8),
                  _buildEditField('Hukuki Sebepler', legalController, maxLines: 6),
                  _buildEditField('Deliller', evidenceController, maxLines: 6),
                  _buildEditField('Sonuç ve İstem', conclusionController, maxLines: 6),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AppState>().updateDocument(
                      header: headerController.text.trim(),
                      plaintiffDetails: plaintiffController.text.trim(),
                      defendantDetails: defendantController.text.trim(),
                      subject: subjectController.text.trim(),
                      incidentNarrative: narrativeController.text.trim(),
                      legalGrounds: legalController.text.trim(),
                      evidenceList: evidenceController.text.trim(),
                      conclusionRequest: conclusionController.text.trim(),
                    );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, {int maxLines = 3}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
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
