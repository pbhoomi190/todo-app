class Language {
  final int id;
  final String name;
  final String languageCode;

  Language({this.id, this.name, this.languageCode});

  static List<Language> listOfLanguage() {
    return <Language> [
      Language(id: 1, name: 'English', languageCode: 'en'),
      Language(id: 2, name: 'Hindi', languageCode: 'hi'),
      Language(id: 3, name: 'French', languageCode: 'fr'),
      Language(id: 4, name: 'Spanish', languageCode: 'es'),
      Language(id: 5, name: 'Gujarati', languageCode: 'gu'),
      Language(id: 6, name: 'Arabic', languageCode: 'ar'),
    ];
  }
}