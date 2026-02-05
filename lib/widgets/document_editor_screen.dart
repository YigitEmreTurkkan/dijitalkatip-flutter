import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../services/pdf_generator.dart';
import '../state/app_state.dart';
import '../theme.dart';

class DocumentEditorScreen extends StatefulWidget {
  final String folderId;
  final Document? existing;

  const DocumentEditorScreen({super.key, required this.folderId, this.existing});

  @override
  State<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends State<DocumentEditorScreen> {
  late final TextEditingController _header;
  late final TextEditingController _plaintiff;
  late final TextEditingController _defendant;
  late final TextEditingController _subject;
  late final TextEditingController _body;
  late final TextEditingController _result;

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    _header = TextEditingController(text: d?.header ?? '');
    _plaintiff = TextEditingController(text: d?.plaintiffDetails ?? '');
    _defendant = TextEditingController(text: d?.defendantDetails ?? '');
    _subject = TextEditingController(text: d?.subject ?? '');
    _body = TextEditingController(text: d?.incidentNarrative ?? '');
    _result = TextEditingController(text: d?.conclusionRequest ?? '');
  }

  @override
  void dispose() {
    _header.dispose();
    _plaintiff.dispose();
    _defendant.dispose();
    _subject.dispose();
    _body.dispose();
    _result.dispose();
    super.dispose();
  }

  Document _buildDoc() {
    final current = widget.existing;
    final id = current?.id.isNotEmpty == true ? current!.id : 'doc-${DateTime.now().millisecondsSinceEpoch}';
    return Document(
      id: id,
      header: _header.text.trim().isEmpty ? null : _header.text.trim(),
      plaintiffDetails: _plaintiff.text.trim().isEmpty ? null : _plaintiff.text.trim(),
      defendantDetails: _defendant.text.trim().isEmpty ? null : _defendant.text.trim(),
      subject: _subject.text.trim().isEmpty ? null : _subject.text.trim(),
      incidentNarrative: _body.text.trim().isEmpty ? null : _body.text.trim(),
      legalGrounds: current?.legalGrounds,
      evidenceList: current?.evidenceList,
      conclusionRequest: _result.text.trim().isEmpty ? null : _result.text.trim(),
      updatedAt: DateTime.now(),
    );
  }

  void _save() {
    final doc = _buildDoc();
    context.read<AppState>().setActiveFolder(widget.folderId);
    context.read<AppState>().upsertDocumentInActiveFolder(doc);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belge kaydedildi.')));
  }

  Future<void> _exportPdf() async {
    final doc = _buildDoc();
    await PdfGenerator.generatePdf(doc);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Belgeyi Düzenle'),
        actions: [
          IconButton(
            tooltip: 'Kaydet',
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportPdf,
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('PDF'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.08)),
              ),
              child: Text(
                'Bu ekran “belge düzenleme” ekranı.\n'
                'Sohbette olayı anlattıktan sonra metni burada kontrol edebilir, istersen değiştirip kaydedebilirsin.\n'
                'Hazır olunca “PDF” ile indirebilirsin.',
                style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            Text('Başlık', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(controller: _header, decoration: const InputDecoration(hintText: 'Örn: Dilekçe Taslağı')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Davacı', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(controller: _plaintiff, decoration: const InputDecoration(hintText: 'Senin bilgilerin (ad/soyad vs.)')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Davalı', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(controller: _defendant, decoration: const InputDecoration(hintText: 'Karşı taraf bilgileri')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Konu', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(controller: _subject, decoration: const InputDecoration(hintText: 'Kısaca ne istiyorsun? (örn. alacağın ödenmesi)')),
            const SizedBox(height: 16),
            Text('Açıklamalar (Gövde)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _body,
              maxLines: 10,
              decoration: const InputDecoration(hintText: 'Olayı adım adım anlatım...'),
            ),
            const SizedBox(height: 16),
            Text('Sonuç ve İstem', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _result,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Sonuçta ne talep ediyorsun?'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

