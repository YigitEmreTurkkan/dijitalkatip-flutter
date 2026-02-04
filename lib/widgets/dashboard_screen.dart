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
            'Bu ekran, aktif davalarınızın ve son tarihlerinizin özetini gösterir.\n'
            'Aşağıdaki adımları izleyerek hızlıca dilekçe oluşturabilirsiniz:',
            style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StepChip(
                number: '1',
                label: 'Sohbet ekranına gidin',
                onTap: onStartChat,
              ),
              _StepChip(
                number: '2',
                label: 'Belge/PDF ekranını açın',
                onTap: onViewDocument,
              ),
              const _StepChip(
                number: '3',
                label: 'Sağ alttan PDF indirin',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Summary cards
          Row(
            children: [
              Expanded(child: _SummaryCard(title: 'Aktif Davalar', value: '3', color: primaryColor)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(title: 'Yaklaşan Son Tarihler', value: '2', color: secondaryColor)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Aktif Davalar',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _CaseCard(
            title: 'Tazminat Davası',
            court: 'İstanbul 3. Asliye Hukuk Mahkemesi',
            parties: 'Müvekkil A.Ş. vs. X Ltd.',
            dueIn: '3 gün kaldı',
          ),
          _CaseCard(
            title: 'İcra Takibi',
            court: 'Ankara 5. İcra Dairesi',
            parties: 'Müvekkil B. vs. Y',
            dueIn: '7 gün kaldı',
          ),
          const SizedBox(height: 24),
          Text(
            'Yaklaşan Son Tarihler',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _DeadlineCard(
            dateLabel: '12 Şubat',
            description: 'Dava dilekçesi sunma süresi',
            matter: 'Tazminat Davası',
          ),
          _DeadlineCard(
            dateLabel: '15 Şubat',
            description: 'İtiraz dilekçesi için son gün',
            matter: 'İcra Takibi',
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


class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Detay',
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final String title;
  final String court;
  final String parties;
  final String dueIn;

  const _CaseCard({
    required this.title,
    required this.court,
    required this.parties,
    required this.dueIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentGoldColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    dueIn,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accentGoldColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              court,
              style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor),
            ),
            const SizedBox(height: 4),
            Text(
              parties,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final String dateLabel;
  final String description;
  final String matter;

  const _DeadlineCard({
    required this.dateLabel,
    required this.description,
    required this.matter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dateLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    matter,
                    style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

