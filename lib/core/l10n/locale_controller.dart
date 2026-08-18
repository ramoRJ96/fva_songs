import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/analytics_client.dart';
import '../analytics/analytics_events.dart';
import '../analytics/analytics_providers.dart';

/// Clé SharedPreferences pour mémoriser la langue choisie.
const _localePrefsKey = 'app_locale_code';

/// Locales supportées par l'application.
const supportedAppLocales = <Locale>[
  Locale('fr'),
  Locale('mg'),
];

/// Contrôleur de locale (FR par défaut, MG au choix).
///
/// Responsabilité unique : lire/écrire la préférence de langue.
class LocaleController extends StateNotifier<Locale> {
  LocaleController(
    this._prefs, {
    AnalyticsClient analytics = const NoOpAnalyticsClient(),
  })  : _analytics = analytics,
        super(_localeFromCode(_prefs.getString(_localePrefsKey)));

  final SharedPreferences _prefs;
  final AnalyticsClient _analytics;

  /// Bascule entre français et malagasy.
  Future<void> toggle() async {
    final next = state.languageCode == 'mg' ? const Locale('fr') : const Locale('mg');
    await setLocale(next);
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == state) return;

    final previous = state.languageCode;
    state = locale;
    await _prefs.setString(_localePrefsKey, locale.languageCode);
    await _analytics.logEvent(
      AnalyticsEvents.localeChange,
      parameters: {
        'from': previous,
        'to': locale.languageCode,
      },
    );
  }

  static Locale _localeFromCode(String? code) {
    if (code == 'mg') return const Locale('mg');
    return const Locale('fr');
  }
}

/// SharedPreferences injecté au démarrage via [ProviderScope.overrides].
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences doit être initialisé dans main()');
});

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(
    ref.watch(sharedPreferencesProvider),
    analytics: ref.watch(analyticsClientProvider),
  );
});
