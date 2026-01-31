class FacultyModel {
  final String id;
  final String? universityId;
  final Map<String, String> name;

  FacultyModel({
    required this.id,
    this.universityId,
    required this.name,
  });

  String getLocalizedName(String locale) {
    return name[locale] ?? name['en'] ?? name.values.first;
  }

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    // Парсим translations массив в Map
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

    return FacultyModel(
      id: json['_id'] as String? ?? json['id'] as String,
      universityId: json['universityId'],
      name: nameMap,
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
      'universityId': universityId,
      'translations': translations,
    };
  }
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return name.values.any((translation) =>
        translation.toLowerCase().contains(lowerQuery)
    );
  }
  FacultyModel copyWith({
    String? id,
    String? universityId,
    Map<String, String>? name,
  }) {
    return FacultyModel(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      name: name ?? this.name,
    );
  }


}