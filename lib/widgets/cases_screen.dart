import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'folder_detail_screen.dart';

class CasesScreen extends StatelessWidget {
  const CasesScreen({super.key});

  List<_TemplateCase> get _templates => const [
        _TemplateCase(
          title: 'Kiracı / Kira artışı',
          description: 'Kira bedeli, tahliye, zam / anlaşmazlık',
          prompt:
              'Kira sözleşmesinde kira artışı ve tahliye konusunda yaşadığım sorunu açıklamak istiyorum. Kiracıya yapılan bildirimler, sözleşme başlangıç tarihi, mevcut kira bedeli ve talep edilen bedel konusunda yardımcı olur musun?',
        ),
        _TemplateCase(
          title: 'Alacak / Ödenmeyen borç',
          description: 'Fatura, senet, hizmet bedeli ödenmedi',
          prompt:
              'Ödenmeyen bir alacağım var. Fatura/senet bilgilerini ve ödenmeyen tutarı belirterek alacağın tahsili için nasıl ilerlemeliyim? Tahsilat için bir dilekçe taslağı oluşturabilir misin?',
        ),
        _TemplateCase(
          title: 'Hakaret / Tehdit',
          description: 'Şikayet/koruma talebi için',
          prompt:
              'Hakaret/tehdit içerikli bir durum yaşıyorum. Olayın tarih/saat, tanıklar ve delillerini içerecek şekilde bir şikayet başvurusu taslağı hazırlayabilir misin?',
        ),
        _TemplateCase(
          title: 'İşten çıkarma / Haklarım',
          description: 'Kıdem/ihbar, fazla mesai, hakaret',
          prompt:
              'İşten çıkarıldım. İşe başlama/çıkış tarihleri, fazla mesai ve hakaret iddiaları için hangi haklara sahibim? Dava/başvuru taslağı hazırlayabilir misin?',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final folders = appState.folders;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateFolder(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('Yeni Dosya'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosyalarım', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Her konu için bir “dosya” aç.\nBelge, not ve kaydettiklerini burada toplarsın.',
              style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text('Hazır konular', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _templates
                  .map(
                    (t) => ActionChip(
                      label: Text(t.title),
                      onPressed: () => _startTemplate(context, t),
                      tooltip: t.description,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: folders.isEmpty
                  ? Center(
                      child: Text(
                        'Henüz dosya yok.\nSağ alttan "Yeni Dosya" ile oluştur.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final f = folders[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.folder_outlined, color: primaryColor),
                            title: Text(f.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            subtitle: f.description == null
                                ? null
                                : Text(
                                    f.description!,
                                    style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor),
                                  ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              context.read<AppState>().setActiveFolder(f.id);
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => FolderDetailScreen(folderId: f.id)),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFolder(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final padding = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: padding.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yeni Dosya', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Dosya adı (örn. Kiracı tahliye, alacak, işten çıkarma)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(hintText: 'Kısa açıklama (opsiyonel)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    context.read<AppState>().createFolder(
                          name: name,
                          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                        );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Oluştur'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startTemplate(BuildContext context, _TemplateCase t) {
    final appState = context.read<AppState>();
    appState.createFolder(name: t.title, description: t.description);
    // Aktif dosyayı seçip, ilk kullanıcı mesajını otomatik gönder
    appState.sendMessage(t.prompt);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('“${t.title}” dosyası açıldı, sohbet başlatıldı.')),
    );
  }
}

class _TemplateCase {
  final String title;
  final String description;
  final String prompt;
  const _TemplateCase({
    required this.title,
    required this.description,
    required this.prompt,
  });
}

