import 'package:agribotics/core/localization/localized_text.dart';
import 'package:agribotics/core/localization/language_controller.dart';
import 'package:agribotics/core/theme/app_theme.dart';
import 'package:agribotics/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languages = [
      ('en', l10n.languageEnglish, 'English'),
      ('hi', l10n.languageHindi, 'हिन्दी'),
      ('ta', l10n.languageTamil, 'தமிழ்'),
      ('te', l10n.languageTelugu, 'తెలుగు'),
      ('kn', l10n.languageKannada, 'ಕನ್ನಡ'),
      ('mr', l10n.languageMarathi, 'मराठी'),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(),
              Text(trText(l10n.languageWelcome), style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.primary)),
              SizedBox(height: 12),
              Text(trText(l10n.languageSelectPrompt), style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 32),
              ...languages.map((language) => Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      tileColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      title: Text(trText(language.$3), style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: language.$2 == language.$3 ? null : Text(trText(language.$2)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () async {
                        await ref.read(languageProvider.notifier).select(language.$1);
                        if (context.mounted) context.go('/dashboard');
                      },
                    ),
                  )),
              Spacer(),
              Text(trText(l10n.languageChangeLater), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
