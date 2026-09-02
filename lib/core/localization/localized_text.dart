import 'package:agribotics/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

class LanguageRuntime {
  LanguageRuntime._();

  static String localeCode = 'en';
}

/// Translates page-owned display copy while keeping measurements, indices,
/// identifiers, API values and unsupported scientific names unchanged.
String trText(String source) =>
    AppLocalizations(Locale(LanguageRuntime.localeCode)).translateSource(source);
