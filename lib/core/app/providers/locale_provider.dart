import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale_code';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _load();
  }

  static const supported = [
    Locale('en'),
    Locale('uk'),
    Locale('ru'),
    Locale('de'),
    Locale('fr'),
    Locale('es'),
    Locale('pt'),
    Locale('it'),
    Locale('pl'),
    Locale('tr'),
    Locale('ar'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('hi'),
    Locale('id'),
    Locale('vi'),
    Locale('th'),
  ];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == null || code.isEmpty) {
      state = null;
      return;
    }
    state = Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
      state = null;
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
      state = locale;
    }
  }
}
