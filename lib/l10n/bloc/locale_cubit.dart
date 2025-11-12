import 'package:unitalk/l10n/domain/repository/locale_repository.dart';
import 'package:unitalk/features/auth/data/datasource/user_remote_datasource.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  final LocaleRepository _repository;
  final UserRemoteDataSource _userDataSource;

  LocaleCubit(this._repository, this._userDataSource) : super(const Locale('en'));

  /// Загружает локальный язык при старте приложения (до авторизации)
  Future<void> loadLocale() async {
    final saved = await _repository.getSavedLocale();
    emit(saved);
  }

  /// Синхронизирует язык после входа пользователя
  /// - isFirstLogin = true: отправляем локальный язык на сервер
  /// - isFirstLogin = false: используем язык с сервера
  Future<void> syncWithUser({
    required String? userLanguage,
    required bool isFirstLogin,
  }) async {
    if (isFirstLogin) {
      // При первом входе (регистрации) - отправляем локальный язык на сервер
      final currentLocale = state;
      print('📝 First login: sending local language to server: ${currentLocale.languageCode}');

      try {
        await _userDataSource.updateLanguage(currentLocale.languageCode);
        print('✅ Local language synced to server');
      } catch (e) {
        print('⚠️ Failed to sync local language to server: $e');
      }
    } else {
      // При повторном входе - используем язык с сервера
      if (userLanguage != null && _isValidLanguage(userLanguage)) {
        final serverLocale = Locale(userLanguage);

        // Только если язык отличается от текущего
        if (serverLocale.languageCode != state.languageCode) {
          print('🌍 Using server language: $userLanguage');
          await _repository.saveLocale(serverLocale);
          emit(serverLocale);
        }
      }
    }
  }

  /// Меняет язык вручную (из настроек) и синхронизирует с сервером
  Future<void> changeLocale(Locale locale) async {
    try {
      // 1. Сохраняем локально сразу для быстрого отклика UI
      await _repository.saveLocale(locale);
      emit(locale);

      // 2. Отправляем на сервер в фоне
      await _userDataSource.updateLanguage(locale.languageCode);
      print('✅ Language synced to server: ${locale.languageCode}');
    } catch (e) {
      // Если ошибка на сервере - не критично, локально уже сохранено
      print('⚠️ Failed to sync language to server: $e');
    }
  }

  bool _isValidLanguage(String code) {
    return ['en', 'ru', 'az'].contains(code);
  }
}