import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fva_songs/core/l10n/locale_controller.dart';

void main() {
  group('LocaleController', () {
    test('démarre en français par défaut si rien n\'est mémorisé', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final controller = LocaleController(prefs);

      expect(controller.state, const Locale('fr'));
    });

    test('restaure la langue mémorisée (mg)', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'mg'});
      final prefs = await SharedPreferences.getInstance();

      final controller = LocaleController(prefs);

      expect(controller.state, const Locale('mg'));
    });

    test('toggle bascule de fr vers mg puis vers fr', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = LocaleController(prefs);

      await controller.toggle();
      expect(controller.state, const Locale('mg'));
      expect(prefs.getString('app_locale_code'), 'mg');

      await controller.toggle();
      expect(controller.state, const Locale('fr'));
      expect(prefs.getString('app_locale_code'), 'fr');
    });

    test('setLocale met à jour l\'état et persiste la préférence', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = LocaleController(prefs);

      await controller.setLocale(const Locale('mg'));

      expect(controller.state, const Locale('mg'));
      expect(prefs.getString('app_locale_code'), 'mg');
    });

    test('code inconnu retombe sur français', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'en'});
      final prefs = await SharedPreferences.getInstance();

      final controller = LocaleController(prefs);

      expect(controller.state, const Locale('fr'));
    });
  });
}
