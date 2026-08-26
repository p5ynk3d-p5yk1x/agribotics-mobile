import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:agribotics/core/providers/app_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _logout(WidgetRef ref,) async {
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Account Settings',
                  style: Theme.of(context).textTheme.headlineLarge,
                ).animate().fadeIn(),
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/default-user=s120-c'),
                ).animate().scale(),
              ],
            ),
            const SizedBox(height: 48),
            _SettingsGroup(
              title: 'PREFERENCES',
              items: [
                _SettingsItem(icon: LucideIcons.user, label: 'Profile Management'),
                _SettingsItem(icon: LucideIcons.bell, label: 'Notification Protocols'),
                _SettingsItem(icon: LucideIcons.shield, label: 'Security & Access'),
              ],
            ),
            const SizedBox(height: 32),
            _SettingsGroup(
              title: 'DATA & EXPORT',
              items: [
                _SettingsItem(icon: LucideIcons.download, label: 'Export Estate Data (JSON/CSV)'),
                _SettingsItem(icon: LucideIcons.cloud, label: 'Cloud Synchronisation'),
              ],
            ),
            const SizedBox(height: 32),
            _SettingsGroup(
              title: 'SUPPORT',
              items: [
                _SettingsItem(icon: LucideIcons.helpCircle, label: 'Technical Documentation'),
                _SettingsItem(icon: LucideIcons.logOut, label: 'Sign Out', isDestructive: true,  onTap: () => _logout(ref),),
              ],
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.secondary),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: items),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0);
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsItem({required this.icon, required this.label, this.isDestructive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppTheme.primary, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : AppTheme.onSurface,
        ),
      ),
      trailing: const Icon(LucideIcons.chevronRight, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}
