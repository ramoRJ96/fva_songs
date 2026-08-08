import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter ne fournit pas Material/Cupertino pour `mg`.
/// On charge donc le français pour ces widgets système (AppBar, etc.),
/// pendant que [AppLocalizations] continue de servir le malagasy.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'mg' ||
        GlobalMaterialLocalizations.delegate.isSupported(locale);
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final effective =
        locale.languageCode == 'mg' ? const Locale('fr') : locale;
    return GlobalMaterialLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'mg' ||
        GlobalCupertinoLocalizations.delegate.isSupported(locale);
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final effective =
        locale.languageCode == 'mg' ? const Locale('fr') : locale;
    return GlobalCupertinoLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<CupertinoLocalizations> old,
  ) =>
      false;
}
