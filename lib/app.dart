import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/routes.dart';
import 'core/localization/language_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:agribotics/l10n/app_localizations.dart';

class TheEstateApp extends ConsumerWidget {
  const TheEstateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final language = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'Agribotics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
