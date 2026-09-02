import 'package:agribotics/core/localization/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _logout(WidgetRef ref,) async {
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trText(l10n.settingsTitle),
                  style: Theme.of(context).textTheme.headlineLarge,
                ).animate().fadeIn(),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/default-user=s120-c'),
                ).animate().scale(),
              ],
            ),
            SizedBox(height: 48),
            _SettingsGroup(
              title: l10n.settingsPreferences,
              items: [
                _SettingsItem(icon: LucideIcons.languages, label: l10n.settingsLanguage, onTap: () => context.go('/language?change=true')),
                _SettingsItem(icon: LucideIcons.user, label: l10n.settingsProfile),
                _SettingsItem(icon: LucideIcons.bell, label: l10n.settingsNotifications),
                _SettingsItem(icon: LucideIcons.shield, label: l10n.settingsSecurity),
              ],
            ),
            SizedBox(height: 32),
            _SettingsGroup(
              title: l10n.settingsDataExport,
              items: [
                _SettingsItem(icon: LucideIcons.download, label: l10n.settingsExport),
                _SettingsItem(icon: LucideIcons.cloud, label: l10n.settingsCloud),
              ],
            ),
            SizedBox(height: 32),
            _SettingsGroup(
              title: l10n.settingsSupport,
              items: [
                _SettingsItem(icon: LucideIcons.helpCircle, label: l10n.settingsDocumentation),
                _SettingsItem(icon: LucideIcons.logOut, label: l10n.settingsSignOut, isDestructive: true,  onTap: () => _logout(ref),),
              ],
            ),
            SizedBox(height: 120),
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
          trText(title),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.secondary),
        ),
        SizedBox(height: 20),
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
        trText(label),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : AppTheme.onSurface,
        ),
      ),
      trailing: Icon(LucideIcons.chevronRight, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}
