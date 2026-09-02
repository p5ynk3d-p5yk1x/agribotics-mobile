import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localized_text.dart';

const supportedLanguageCodes = ['en', 'hi', 'ta', 'te', 'kn', 'mr'];

@immutable
class LanguageState {
  const LanguageState({required this.isLoading, this.locale});

  const LanguageState.loading() : this(isLoading: true);

  final bool isLoading;
  final Locale? locale;

  bool get hasPreference => locale != null;
}

class LanguageController extends StateNotifier<LanguageState> {
  LanguageController() : super(const LanguageState.loading()) {
    _load();
  }

  static const _preferenceKey = 'preferred_language';

  Future<void> _load() async {
    final code = (await SharedPreferences.getInstance()).getString(_preferenceKey);
    if (supportedLanguageCodes.contains(code)) LanguageRuntime.localeCode = code!;
    state = LanguageState(
      isLoading: false,
      locale: supportedLanguageCodes.contains(code) ? Locale(code!) : null,
    );
  }

  Future<void> select(String languageCode) async {
    if (!supportedLanguageCodes.contains(languageCode)) return;
    await (await SharedPreferences.getInstance()).setString(_preferenceKey, languageCode);
    LanguageRuntime.localeCode = languageCode;
    state = LanguageState(isLoading: false, locale: Locale(languageCode));
  }
}

final languageProvider = StateNotifierProvider<LanguageController, LanguageState>(
  (ref) => LanguageController(),
);
