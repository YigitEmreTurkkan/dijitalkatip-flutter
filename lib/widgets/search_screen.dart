import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../models/research_item.dart';
import '../services/emsal_service.dart';
import '../state/app_state.dart';
import '../theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final EmsalService _emsalService = EmsalService();
  bool _isSearching = false;
  List<ResearchItem> _results = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _isSearching = true;
      _results = const [];
    });
    if (kIsWeb && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('UYAP Emsal araması webde CORS nedeniyle kısıtlı olabilir. Mobil/masaüstünde deneyin.'),
        ),
      );
    }

    try {
      final results = await _emsalService.search(q, pageSize: 15);
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _results = results;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _results = const [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emsal araması şu an kullanılamıyor. Lütfen tekrar deneyin.')),
      );
    }
  }

  void _openDecision(ResearchItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.title),
          content: FutureBuilder<String?>(
            future: _emsalService.fetchDecisionText(item.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final text = snapshot.data;
              if (text == null || text.isEmpty) {
                return const Text('Karar içeriği alınamadı.');
              }
              return SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: SelectableText(text),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final activeFolder = appState.activeFolder;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emsal Bul', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Bu ekran, benzer karar/mevzuat örneklerini bulmana yardım eder.\n'
              'UYAP Emsal üzerinden arama yapar; sonuçları “Dosyalarım”a kaydedebilirsin.',
              style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor, height: 1.4),
            ),
            const SizedBox(height: 12),
            if (activeFolder != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_outlined, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kaydedilecek dosya: ${activeFolder.name}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      hintText: 'Örn: kira artışı, alacak, tehdit, hakaret...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSearching ? null : _search,
                  child: _isSearching
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Ara'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? _buildEmpty(theme)
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(item.snippet, style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor, height: 1.3)),
                            ),
                          onTap: () => _openDecision(item),
                            trailing: IconButton(
                              tooltip: 'Klasöre kaydet',
                              icon: const Icon(Icons.bookmark_add_outlined),
                              onPressed: activeFolder == null
                                  ? null
                                  : () {
                                      context.read<AppState>().saveResearchToActiveFolder(item);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Dosyaya kaydedildi.')),
                                      );
                                    },
                            ),
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

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Text(
        'Arama yapmak için anahtar kelime yazıp "Ara"ya bas.',
        style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}

