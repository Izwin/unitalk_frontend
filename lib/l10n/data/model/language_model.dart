enum Language {
  english('en', 'English', '🇬🇧'),
  russian('ru', 'Русский', '🇷🇺'),
  azerbaijani('az', 'Azərbaycan', '🇦🇿');

  final String countryCode;
  final String displayName;
  final String flag;

  const Language(this.countryCode, this.displayName, this.flag);

  static Language fromCode(String? code) {
    switch (code) {
      case 'en':
        return Language.english;
      case 'ru':
        return Language.russian;
      case 'az':
        return Language.azerbaijani;
      default:
        return Language.english; // Язык по умолчанию
    }
  }

  @override
  String toString() => '$flag $displayName';
}