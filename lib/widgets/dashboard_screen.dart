import 'package:flutter/material.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onStartChat;
  final VoidCallback? onViewDocument;

  const DashboardScreen({super.key, this.onStartChat, this.onViewDocument});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hoş geldiniz,', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Dijital Katip', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Hukuki durumunu anlat, sana uygun bir dilekçe taslağı hazırlayalım.\n'
            'Sonra “Belgem” sekmesinden metni görür, istersen PDF olarak indirirsin.\n\n'
            '3 adım:',
            style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StepChip(
                number: '1',
                label: 'Sohbetten olayı anlat',
                onTap: onStartChat,
              ),
              _StepChip(
                number: '2',
                label: 'Belgem sekmesine bak',
                onTap: onViewDocument,
              ),
              const _StepChip(
                number: '3',
                label: 'PDF indir',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Neyi yapıyoruz?', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Bu uygulama bir avukat yerine geçmez.\n'
                    'Ama dilekçe taslağı oluşturmanı ve düzenlemeni çok hızlandırır.\n\n'
                    'İpucu: En başta sadece “Ne oldu?” sorusuna cevap ver. Detayları ben tek tek sorarım.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final String number;
  final String label;
  final VoidCallback? onTap;

  const _StepChip({
    required this.number,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: primaryColor,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.blueGrey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}


// (Removed lawyer-oriented dashboard cards for consumer-first UX)

