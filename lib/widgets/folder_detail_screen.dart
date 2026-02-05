import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'document_editor_screen.dart';

class FolderDetailScreen extends StatelessWidget {
  final String folderId;
  const FolderDetailScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final folder = appState.folders.firstWhere((f) => f.id == folderId);
    final docs = appState.documentsForFolder(folderId);
    final research = appState.researchForFolder(folderId);

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DocumentEditorScreen(folderId: folderId)),
          );
        },
        icon: const Icon(Icons.edit_document),
        label: const Text('Yeni Belge'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: ListView(
          children: [
            if (folder.description != null)
              Text(folder.description!, style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor)),
            const SizedBox(height: 16),
            Text('Belgeler', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (docs.isEmpty)
              Text('Henüz belge yok. "Yeni Belge" ile oluştur.', style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor))
            else
              ...docs.map((d) => _DocumentRow(doc: d, folderId: folderId)),
            const SizedBox(height: 24),
            Text('Kaydedilen İçtihat / Mevzuat', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (research.isEmpty)
              Text('Henüz kayıt yok. "Arama" ekranından kaydet.', style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor))
            else
              ...research.map(
                (r) => Card(
                  child: ListTile(
                    title: Text(r.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text(r.snippet, style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor)),
                    trailing: Text(r.source, style: theme.textTheme.labelSmall?.copyWith(color: mutedTextColor)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final Document doc;
  final String folderId;
  const _DocumentRow({required this.doc, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (doc.header == null || doc.header!.trim().isEmpty) ? 'Belge' : doc.header!.trim();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description_outlined, color: primaryColor),
        title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Güncelleme: ${doc.updatedAt}',
          style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DocumentEditorScreen(folderId: folderId, existing: doc),
            ),
          );
        },
      ),
    );
  }
}

