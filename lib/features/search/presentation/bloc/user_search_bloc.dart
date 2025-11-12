import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/search/domain/repository/user_search_repository.dart';

import 'user_search_event.dart';
import 'user_search_state.dart';

class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final UserSearchRepository repository;

  UserSearchBloc({required this.repository}) : super(UserSearchState.initial()) {
    on<SearchUsersEvent>(_onSearchUsers);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchUsers(
      SearchUsersEvent event,
      Emitter<UserSearchState> emit,
      ) async {
    // Валидация запроса
    if (event.query.trim().length < 2) {
      emit(state.copyWith(
        status: UserSearchStatus.failure,
        errorMessage: 'Search query must be at least 2 characters',
      ));
      return;
    }

    // Если загружаем больше данных
    if (event.loadMore) {
      // Проверяем, что уже есть результаты и есть еще данные для загрузки
      if (state.users.isEmpty || !state.hasMore) {
        return;
      }

      // Проверяем, что уже не загружаем данные
      if (state.status == UserSearchStatus.loadingMore) {
        return;
      }

      emit(state.copyWith(status: UserSearchStatus.loadingMore));
    } else {
      // Новый поиск - сбрасываем состояние
      emit(state.copyWith(
        status: UserSearchStatus.loading,
        users: [],
        offset: 0,
        total: 0,
        hasMore: false,
        errorMessage: null,
      ));
    }

    // Вычисляем offset - используем количество уже загруженных пользователей
    final offset = event.loadMore ? state.users.length : 0;

    try {
      // Выполняем запрос
      final result = await repository.searchUsers(
        query: event.query,
        facultyId: event.facultyId,
        universityId: event.universityId,
        sector: event.sector,
        limit: state.limit,
        offset: offset,
      );

      // Обрабатываем результат
      result.fold(
            (failure) {
          emit(state.copyWith(
            status: UserSearchStatus.failure,
            errorMessage: failure.message,
          ));
        },
            (response) {
              print(response.total.toString()
                  + 'fsdfds');
          // Объединяем пользователей если это loadMore
          final updatedUsers = event.loadMore
              ? [...state.users, ...response.users]
              : response.users;

          // Вычисляем hasMore на основе общего количества
          final hasMore = updatedUsers.length < response.total;

          emit(state.copyWith(
            status: UserSearchStatus.success,
            users: updatedUsers,
            query: event.query,
            total: response.total,
            offset: updatedUsers.length, // Обновляем offset на количество загруженных
            limit: response.limit,
            hasMore: hasMore,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: UserSearchStatus.failure,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  void _onClearSearch(
      ClearSearchEvent event,
      Emitter<UserSearchState> emit,
      ) {
    emit(UserSearchState.initial());
  }
}