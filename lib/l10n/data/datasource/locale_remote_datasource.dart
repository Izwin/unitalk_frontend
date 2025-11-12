import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LocaleRemoteDataSource {
  static const String _baseUrl = 'https://your-api.com/api';

  final Dio dio;
  final FirebaseAuth firebaseAuth;

  LocaleRemoteDataSource({
    required this.dio,
    required this.firebaseAuth,
  });

  /// Получение текущего языка пользователя с backend'а
  Future<Locale> fetchUserLocale({String? fallbackLanguageCode = 'en'}) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      return Locale(fallbackLanguageCode ?? 'en');
    }

    try {
      final token = await user.getIdToken();
      final response = await dio.get(
        '$_baseUrl/users/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-language': fallbackLanguageCode ?? 'en',
          },
        ),
      );

      if (response.statusCode == 200) {
        final backendLanguage = response.data['language'] as String?;
        return Locale(backendLanguage ?? fallbackLanguageCode ?? 'en');
      } else {
        throw Exception('Failed to fetch user locale');
      }
    } catch (e) {
      print('Error fetching locale: $e');
      return Locale(fallbackLanguageCode ?? 'en');
    }
  }

  /// Отправка выбранного языка пользователя на backend
  Future<void> updateUserLocale(Locale locale) async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final token = await user.getIdToken();
      await dio.put(
        '$_baseUrl/users/profile',
        data: {
          'language': locale.languageCode,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-language': locale.languageCode,
          },
        ),
      );

      print('Locale updated successfully: ${locale.languageCode}');
    } catch (e) {
      print('Error updating locale: $e');
      rethrow;
    }
  }

  /// Список поддерживаемых языков можно получить с backend'а
  Future<List<Locale>> fetchSupportedLocales() async {
    try {
      final response = await dio.get('$_baseUrl/locales');

      if (response.statusCode == 200 && response.data is List) {
        final locales = (response.data as List)
            .map((code) => Locale(code.toString()))
            .toList();
        return locales;
      } else {
        throw Exception('Failed to load supported locales');
      }
    } catch (e) {
      print('Error fetching supported locales: $e');
      // Фоллбэк на стандартные языки
      return const [Locale('en'), Locale('ru'), Locale('az')];
    }
  }
}
