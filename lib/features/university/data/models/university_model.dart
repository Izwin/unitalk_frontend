class UniversityModel{
  final String id;
  final Map<String, String> name;
  final String? logoUrl;

  UniversityModel({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  String getLocalizedName(String locale) {
    return name[locale] ?? name['en'] ?? name.values.first;
  }

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    final Map<String, String> nameMap = {};

    if (json['translations'] != null) {
      for (var translation in json['translations']) {
        nameMap[translation['lang']] = translation['name'];
      }
    }

    // Fallback на старую структуру если есть
    if (nameMap.isEmpty && json['name'] != null) {
      nameMap.addAll(Map<String, String>.from(json['name'] as Map));
    }

    return UniversityModel(
      id: json['_id'] as String? ?? json['id'] as String,
      name: nameMap,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    // Конвертируем обратно в массив translations
    final translations = name.entries.map((entry) {
      return {
        'lang': entry.key,
        'name': entry.value,
      };
    }).toList();

    return {
      'id': id,
      'translations': translations,
      'logoUrl': logoUrl,
    };
  }

}