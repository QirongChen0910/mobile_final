import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A class that handles localization of strings in the application.
///
/// This class loads and provides localized strings based on the current locale.
class AppLocalizations {
  /// Creates an instance of `AppLocalizations` with the given [locale].
  ///
  /// [locale] The locale that specifies the language and region for localization.
  AppLocalizations(this.locale) {
    _localizedStrings = <String, String>{};
  }

  /// Returns the current instance of `AppLocalizations` from the [context].
  ///
  /// [context] The build context from which to retrieve the localization instance.
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Provides a delegate for `AppLocalizations` to handle localization in the application.
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  /// The locale associated with this instance of `AppLocalizations`.
  final Locale locale;

  /// A map that holds localized strings with their corresponding keys.
  late Map<String, String> _localizedStrings;

  /// Loads localized strings from a JSON file based on the current [locale].
  ///
  /// The JSON file is expected to be located at `assets/translations/{locale.languageCode}.json`.
  Future<void> load() async {
    String jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  /// Translates a given [key] to the corresponding localized string.
  ///
  /// [key] The key used to look up the localized string.
  /// Returns the localized string corresponding to the [key], or `null` if not found.
  String? translate(String key) {
    return _localizedStrings[key];
  }
}

/// A delegate that handles the creation and loading of `AppLocalizations` instances.
///
/// This delegate is used by the Flutter framework to provide localized strings.
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  /// Creates an instance of `_AppLocalizationsDelegate`.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // You can specify supported locales here. For now, it returns true for all locales.
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
