import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: primaryColor,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Av. Adınız Soyadınız',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'İstanbul Barosu • Sicil No: 123456',
                  style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Hesap',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _ProfileTile(
                  title: 'Kişisel Bilgiler',
                  subtitle: 'Ad, iletişim bilgileri, baro kaydı',
                  icon: Icons.badge_outlined,
                ),
                const Divider(height: 1),
                _ProfileTile(
                  title: 'Bildirimler',
                  subtitle: 'Son tarih ve durum bildirimleri',
                  icon: Icons.notifications_outlined,
                ),
                const Divider(height: 1),
                _ProfileTile(
                  title: 'Güvenlik',
                  subtitle: 'Oturum ve cihaz yönetimi',
                  icon: Icons.lock_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Uygulama',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: const [
                _ProfileTile(
                  title: 'Tema',
                  subtitle: 'Aydınlık / Karanlık tema',
                  icon: Icons.brightness_6_outlined,
                ),
                Divider(height: 1),
                _ProfileTile(
                  title: 'Hakkında',
                  subtitle: 'Sürüm bilgisi ve gizlilik',
                  icon: Icons.info_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade700,
              ),
              child: const Text('Oturumu Kapat'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ProfileTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(color: mutedTextColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

