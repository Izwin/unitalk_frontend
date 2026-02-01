import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/friendship/data/model/friendship_model.dart'
    show FriendshipStatusResponse, FriendshipStatus;
import 'package:unitalk/features/friendship/domain/repository/friendship_repository.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_state.dart'
    show FriendshipState, FriendshipStateStatus;
import 'friendship_event.dart';

class FriendshipBloc extends Bloc<FriendshipEvent, FriendshipState> {
  final FriendshipRepository repository;

  FriendshipBloc({required this.repository})
    : super(FriendshipState.initial()) {
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<RejectFriendRequestEvent>(_onRejectFriendRequest);
    on<RemoveFriendshipEvent>(_onRemoveFriendship);
    on<LoadFriendsListEvent>(_onLoadFriendsList);
    on<LoadIncomingRequestsEvent>(_onLoadIncomingRequests);
    on<LoadOutgoingRequestsEvent>(_onLoadOutgoingRequests);
    on<LoadFriendshipStatusEvent>(_onLoadFriendshipStatus);
    on<ClearFriendshipStateEvent>(_onClearState);
  }

  Future<void> _onLoadFriendsList(
    LoadFriendsListEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    if (event.loadMore) {
      if (!state.friendsHasMore || state.isLoadingMore) return;
      emit(state.copyWith(status: FriendshipStateStatus.loadingMore));
    } else {
      emit(
        state.copyWith(
          status: FriendshipStateStatus.loading,
          friends: [],
          friendsPage: 1,
        ),
      );
    }

    final page = event.loadMore ? state.friendsPage : 1;

    final result = await repository.getFriendsList(page: page, limit: 20,userId: event.userId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: FriendshipStateStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (newFriends) {
        final updatedFriends = event.loadMore
            ? [...state.friends, ...newFriends]
            : newFriends;

        emit(
          state.copyWith(
            status: FriendshipStateStatus.success,
            friends: updatedFriends,
            friendsPage: page + 1,
            friendsHasMore: newFriends.length >= 20,
          ),
        );
      },
    );
  }

  // Загрузить входящие запросы
  Future<void> _onLoadIncomingRequests(
    LoadIncomingRequestsEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    if (event.loadMore) {
      if (!state.incomingHasMore || state.isLoadingMore) return;
      emit(state.copyWith(status: FriendshipStateStatus.loadingMore));
    } else {
      emit(
        state.copyWith(
          status: FriendshipStateStatus.loading,
          incomingRequests: [],
          incomingPage: 1,
        ),
      );
    }

    final page = event.loadMore ? state.incomingPage : 1;

    final result = await repository.getIncomingRequests(page: page, limit: 20);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: FriendshipStateStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (newRequests) {
        final updatedRequests = event.loadMore
            ? [...state.incomingRequests, ...newRequests]
            : newRequests;

        emit(
          state.copyWith(
            status: FriendshipStateStatus.success,
            incomingRequests: updatedRequests,
            incomingPage: page + 1,
            incomingHasMore: newRequests.length >= 20,
          ),
        );
      },
    );
  }

  // Загрузить исходящие запросы
  Future<void> _onLoadOutgoingRequests(
    LoadOutgoingRequestsEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    if (event.loadMore) {
      if (!state.outgoingHasMore || state.isLoadingMore) return;
      emit(state.copyWith(status: FriendshipStateStatus.loadingMore));
    } else {
      emit(
        state.copyWith(
          status: FriendshipStateStatus.loading,
          outgoingRequests: [],
          outgoingPage: 1,
        ),
      );
    }

    final page = event.loadMore ? state.outgoingPage : 1;

    final result = await repository.getOutgoingRequests(page: page, limit: 20);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: FriendshipStateStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (newRequests) {
        final updatedRequests = event.loadMore
            ? [...state.outgoingRequests, ...newRequests]
            : newRequests;

        emit(
          state.copyWith(
            status: FriendshipStateStatus.success,
            outgoingRequests: updatedRequests,
            outgoingPage: page + 1,
            outgoingHasMore: newRequests.length >= 20,
          ),
        );
      },
    );
  }

  // Загрузить статус дружбы с пользователем
  Future<void> _onLoadFriendshipStatus(
    LoadFriendshipStatusEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    final result = await repository.getFriendshipStatus(event.userId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: FriendshipStateStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (status) {
        final updatedStatuses = Map<String, FriendshipStatusResponse>.from(
          state.friendshipStatuses,
        );
        updatedStatuses[event.userId] = status;

        emit(
          state.copyWith(
            status: FriendshipStateStatus.success,
            friendshipStatuses: updatedStatuses,
          ),
        );
      },
    );
  }

  // Очистить состояние
  void _onClearState(
    ClearFriendshipStateEvent event,
    Emitter<FriendshipState> emit,
  ) {
    emit(FriendshipState.initial());
  }

  // Отправить запрос в друзья
  Future<void> _onSendFriendRequest(
    SendFriendRequestEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    final result = await repository.sendFriendRequest(event.userId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: FriendshipStateStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (friendship) {
        // ✅ ИСПРАВЛЕНО: Используем правильный тип
        final updatedStatuses = Map<String, FriendshipStatusResponse>.from(
          state.friendshipStatuses,
        );

        updatedStatuses[event.userId] = FriendshipStatusResponse(
          status: FriendshipStatus.pending,
          isFriend: false,
          friendshipId: friendship.id ?? friendship.friendshipId,
          isRequester: true,
          createdAt: friendship.createdAt ?? DateTime.now(),
        );

        emit(
          state.copyWith(
            status: FriendshipStateStatus.success,
            friendshipStatuses: updatedStatuses,
          ),
        );
      },
    );
  }

  // Удалить дружбу
  Future<void> _onRemoveFriendship(
    RemoveFriendshipEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    final result = await repository.removeFriendship(event.friendshipId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: FriendshipStateStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        // ✅ ИСПРАВЛЕНО: Приоритет event.userId
        String? targetUserId = event.userId;

        // Если userId не передан, ищем в списках
        if (targetUserId == null) {
          // Ищем в исходящих запросах
          for (final request in state.outgoingRequests) {
            if (request.friendshipId == event.friendshipId) {
              targetUserId = request.user.id;
              break;
            }
          }

          // Ищем в друзьях
          if (targetUserId == null) {
            for (final friend in state.friends) {
              // Можно добавить поле friendshipId в модель или искать по другому
              // Пока пропускаем, так как в списке друзей нет friendshipId
            }
          }

          // ✅ НОВОЕ: Ищем в friendshipStatuses по friendshipId
          if (targetUserId == null) {
            for (final entry in state.friendshipStatuses.entries) {
              if (entry.value.friendshipId == event.friendshipId) {
                targetUserId = entry.key;
                break;
              }
            }
          }
        }

        // Обновляем списки
        final updatedFriends = state.friends
            .where((friend) => friend.id != targetUserId)
            .toList();

        final updatedOutgoing = state.outgoingRequests
            .where((req) => req.friendshipId != event.friendshipId)
            .toList();

        // Обновляем статусы
        final updatedStatuses = Map<String, FriendshipStatusResponse>.from(
          state.friendshipStatuses,
        );

        if (targetUserId != null) {
          updatedStatuses[targetUserId] = FriendshipStatusResponse(
            status: FriendshipStatus.none,
            isFriend: false,
          );
        }

        emit(
          state.copyWith(
            status: FriendshipStateStatus.success,
            friends: updatedFriends,
            outgoingRequests: updatedOutgoing,
            friendshipStatuses: updatedStatuses,
          ),
        );
      },
    );
  }

  // ✅ ИЗМЕНИТЬ методы _onAcceptFriendRequest и _onRejectFriendRequest

// Принять запрос в друзья
  Future<void> _onAcceptFriendRequest(
      AcceptFriendRequestEvent event,
      Emitter<FriendshipState> emit,
      ) async {
    final result = await repository.acceptFriendRequest(event.friendshipId);

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            status: FriendshipStateStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
          (friendship) {
        String? targetUserId;

        // Ищем в incomingRequests (работает на странице входящих)
        for (final request in state.incomingRequests) {
          if (request.friendshipId == event.friendshipId) {
            targetUserId = request.user.id;
            break;
          }
        }

        // Fallback: ищем в friendshipStatuses по friendshipId
        // (работает на профиле пользователя, где incomingRequests не загружены)
        if (targetUserId == null) {
          for (final entry in state.friendshipStatuses.entries) {
            if (entry.value.friendshipId == event.friendshipId) {
              targetUserId = entry.key;
              break;
            }
          }
        }

        final updatedIncoming = state.incomingRequests
            .where((req) => req.friendshipId != event.friendshipId)
            .toList();

        final updatedStatuses = Map<String, FriendshipStatusResponse>.from(
          state.friendshipStatuses,
        );

        if (targetUserId != null) {
          updatedStatuses[targetUserId] = FriendshipStatusResponse(
            status: FriendshipStatus.accepted,
            isFriend: true,
            friendshipId: event.friendshipId,
            acceptedAt: DateTime.now(),
          );
        }

        emit(
          state.copyWith(
            status: FriendshipStateStatus.success,
            incomingRequests: updatedIncoming,
            friendshipStatuses: updatedStatuses,
          ),
        );

        // ❌ Убрали add(LoadFriendshipStatusEvent) — он перезаписывал
        //    только что установленный 'accepted' статус пустым ответом с сервера
        // ❌ Убрали add(LoadFriendsListEvent) — полная перезагрузка списка
        //    не нужна, кнопка уже обновлена локально
      },
    );
  }

  // Отклонить запрос в друзья
  Future<void> _onRejectFriendRequest(
      RejectFriendRequestEvent event,
      Emitter<FriendshipState> emit,
      ) async {
    final result = await repository.rejectFriendRequest(event.friendshipId);

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            status: FriendshipStateStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
          (_) {
        String? targetUserId;

        // Ищем в incomingRequests
        for (final request in state.incomingRequests) {
          if (request.friendshipId == event.friendshipId) {
            targetUserId = request.user.id;
            break;
          }
        }

        // Fallback: ищем в friendshipStatuses по friendshipId
        if (targetUserId == null) {
          for (final entry in state.friendshipStatuses.entries) {
            if (entry.value.friendshipId == event.friendshipId) {
              targetUserId = entry.key;
              break;
            }
          }
        }

        final updatedIncoming = state.incomingRequests
            .where((req) => req.friendshipId != event.friendshipId)
            .toList();

        final updatedStatuses = Map<String, FriendshipStatusResponse>.from(
          state.friendshipStatuses,
        );

        if (targetUserId != null) {
          updatedStatuses[targetUserId] = FriendshipStatusResponse(
            status: FriendshipStatus.none, // после отклонения — none, не rejected
            isFriend: false,
          );
        }

        emit(
          state.copyWith(
            status: FriendshipStateStatus.success,
            incomingRequests: updatedIncoming,
            friendshipStatuses: updatedStatuses,
          ),
        );

        // ❌ Убрали add(LoadFriendshipStatusEvent) — та же причина
      },
    );
  }
}
