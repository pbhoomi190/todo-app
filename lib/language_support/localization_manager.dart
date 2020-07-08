import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class LocalizationManager {
  final Locale locale;
  LocalizationManager({this.locale});

  static LocalizationManager of(BuildContext context) {
    return Localizations.of<LocalizationManager>(context, LocalizationManager);
  }

  Map<String, String> langValues;

  Future load() async {
    String jsonString = await rootBundle.loadString('lib/language_support/${locale.languageCode}.json');

    Map<String, dynamic> mappedJson = json.decode(jsonString);

    langValues = mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String getTranslatedValue(String key) {
    return langValues[key];
  }

}


class LocalizationManagerDelegate extends LocalizationsDelegate<LocalizationManager> {

  const LocalizationManagerDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'fr', 'es', 'ar', 'gu'].contains(locale.languageCode);
  }

  @override
  Future<LocalizationManager> load(Locale locale) async {
    LocalizationManager localization = LocalizationManager(locale: locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<LocalizationManager> old) {
    return false;
  }

}