import 'dart:convert';
import 'dart:io';

import 'package:agribotics/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all requested languages are supported', () {
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
      containsAll(<String>['en', 'hi', 'ta', 'te', 'kn', 'mr']),
    );
  });

  test('catalog returns the selected language', () {
    expect(AppLocalizations(const Locale('hi')).settingsLanguage, 'भाषा');
    expect(AppLocalizations(const Locale('ta')).landYourLand, 'உங்கள் நிலம்');
    expect(AppLocalizations(const Locale('te')).sharedMarket, 'మార్కెట్');
    expect(AppLocalizations(const Locale('kn')).settingsSignOut, 'ಸೈನ್ ಔಟ್');
    expect(AppLocalizations(const Locale('mr')).languageMarathi, 'मराठी');
  });

  test('every locale contains the complete page-grouped message set', () {
    final catalogs = ['en', 'hi', 'ta', 'te', 'kn', 'mr']
        .map((code) => jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>)
        .toList();
    final englishKeys = catalogs.first.keys.where((key) => !key.startsWith('@')).toSet();

    expect(englishKeys.length, greaterThan(300));
    for (final catalog in catalogs.skip(1)) {
      expect(catalog.keys.where((key) => !key.startsWith('@')).toSet(), englishKeys);
      expect(catalog.values.any((value) => value is String && RegExp(r'[\u0900-\u0D7F]').hasMatch(value)), isTrue);
    }
    expect(englishKeys.any((key) => key.startsWith('soil_')), isTrue);
    expect(englishKeys.any((key) => key.startsWith('land_')), isTrue);
  });

  test('legacy page copy resolves through the selected catalog', () {
    expect(
      AppLocalizations(Locale('hi')).translateSource('Mark Your Land'),
      'अपनी भूमि चिह्नित करें',
    );
    expect(
      AppLocalizations(Locale('ta')).translateSource('No products found.'),
      'தயாரிப்புகள் எதுவும் இல்லை.',
    );
  });
}
