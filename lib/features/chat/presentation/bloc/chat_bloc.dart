import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/services/chat_socker_service.dart';
import 'package:unitalk/features/chat/data/model/message_model.dart';
import 'package:unitalk/features/chat/domain/repository/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final ChatSocketService socketService;

  StreamSubscription? _newMessageSubscription;
  StreamSubscription? _messageEditedSubscription;
  StreamSubscription? _messageDeletedSubscription;
  StreamSubscription? _userJoinedSubscription;
  StreamSubscription? _userLeftSubscription;
  StreamSubscription? _userTypingSubscription;
  StreamSubscription? _userStoppedTypingSubscription;
  StreamSubscription? _onlineUsersSubscription;
  StreamSubscription? _messagesReadSubscription;
  StreamSubscription? _connectionStatusSubscription;

  Timer? _typingTimer;

  ChatBloc({
    required this.chatRepository,
    required this.socketService,
  }) : super(ChatState.initial()) {
    on<LoadParticipantsEvent>(_onLoadParticipants);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<LoadMoreMessagesEvent>(_onLoadMoreMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<EditMessageEvent>(_onEditMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<ConnectSocketEvent>(_onConnectSocket);
    on<DisconnectSocketEvent>(_onDisconnectSocket);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
    on<MessageEditedReceivedEvent>(_onMessageEditedReceived);
    on<MessageDeletedReceivedEvent>(_onMessageDeletedReceived);
    on<StartTypingEvent>(_onStartTyping);
    on<StopTypingEvent>(_onStopTyping);
    on<UserTypingReceivedEvent>(_onUserTypingReceived);
    on<UserStoppedTypingReceivedEvent>(_onUserStoppedTypingReceived);
    on<GetOnlineUsersEvent>(_onGetOnlineUsers);
    on<OnlineUsersReceivedEvent>(_onOnlineUsersReceived);
    on<UserJoinedReceivedEvent>(_onUserJoinedReceived);
    on<UserLeftReceivedEvent>(_onUserLeftReceived);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
    on<MessagesReadReceivedEvent>(_onMessagesReadReceived);
    on<LoadChatInfoEvent>(_onLoadChatInfo);
    on<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _newMessageSubscription = socketService.newMessage.listen((message) {
      add(NewMessageReceivedEvent(message: message));
    });

    _messageEditedSubscription = socketService.messageEdited.listen((message) {
      add(MessageEditedReceivedEvent(message: message));
    });

    _messageDeletedSubscription = socketService.messageDeleted.listen((data) {
      add(MessageDeletedReceivedEvent(messageId: data['messageId'] as String));
    });

    _userJoinedSubscription = socketService.userJoined.listen((user) {
      add(UserJoinedReceivedEvent(user: user));
    });

    _userLeftSubscription = socketService.userLeft.listen((userId) {
      add(UserLeftReceivedEvent(userId: userId));
    });

    _userTypingSubscription = socketService.userTyping.listen((data) {
      add(UserTypingReceivedEvent(
        userId: data['userId'] as String,
        firstName: data['firstName'] as String,
        lastName: data['lastName'] as String,
      ));
    });

    _userStoppedTypingSubscription = socketService.userStoppedTyping.listen((userId) {
      add(UserStoppedTypingReceivedEvent(userId: userId));
    });

    _onlineUsersSubscription = socketService.onlineUsers.listen((users) {
      add(OnlineUsersReceivedEvent(users: users));
    });

    _messagesReadSubscription = socketService.messagesRead.listen((data) {
      add(MessagesReadReceivedEvent(
        userId: data['userId'] as String,
        lastReadMessageId: data['lastReadMessageId'] as String,
        timestamp: DateTime.parse(data['timestamp'] as String),
      ));
    });

    _connectionStatusSubscription = socketService.connectionStatus.listen((isConnected) {
      add(ConnectionStatusChangedEvent(isConnected: isConnected));
    });
  }

  Future<void> _onLoadParticipants(
      LoadParticipantsEvent event,
      Emitter<ChatState> emit,
      ) async {
    final result = await chatRepository.getParticipants();

    result.fold(
          (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
          (participants) => emit(state.copyWith(
        participants: participants,
      )),
    );
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(state.copyWith(status: ChatStatus.loading, clearError: true));

    final result = await chatRepository.getMessages(
      page: event.page,
      limit: event.limit,
      before: event.before,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: failure.message,
      )),
          (messages) {
        // ИСПРАВЛЕНО: Правильная логика определения oldestTimestamp
        // Сообщения приходят отсортированные от новых к старым (createdAt: -1)
        // Последнее сообщение в списке - самое старое
        print('Loaded ${messages.length} messages');
        if (messages.isNotEmpty) {
          print('First message (newest): ${messages.first.createdAt}');
          print('Last message (oldest): ${messages.last.createdAt}');
        }

        emit(state.copyWith(
          status: ChatStatus.success,
          messages: messages,
          hasMore: messages.length >= event.limit,
          // ИСПРАВЛЕНО: берем timestamp последнего (самого старого) сообщения
          oldestTimestamp: messages.isNotEmpty ? messages.last.createdAt : null,
        ));
      },
    );
  }

  Future<void> _onLoadMoreMessages(
      LoadMoreMessagesEvent event,
      Emitter<ChatState> emit,
      ) async {
    print('LoadMore: hasMore=${state.hasMore}, status=${state.status}, oldestTimestamp=${state.oldestTimestamp}');

    if (!state.hasMore || state.status == ChatStatus.loadingMore) {
      print('LoadMore: Skipping - hasMore=${state.hasMore}, isLoading=${state.status == ChatStatus.loadingMore}');
      return;
    }

    // ИСПРАВЛЕНО: Проверяем наличие oldestTimestamp
    if (state.oldestTimestamp == null) {
      print('LoadMore: Skipping - no oldestTimestamp');
      return;
    }

    emit(state.copyWith(status: ChatStatus.loadingMore));

    final result = await chatRepository.getMessages(
      before: state.oldestTimestamp,
      limit: 50,
    );

    result.fold(
          (failure) {
        print('LoadMore: Error - ${failure.message}');
        emit(state.copyWith(
          status: ChatStatus.failure,
          errorMessage: failure.message,
        ));
      },
          (messages) {
        print('LoadMore: Loaded ${messages.length} more messages');

        // ИСПРАВЛЕНО: Предотвращаем дублирование сообщений
        final existingIds = state.messages.map((m) => m.id).toSet();
        final newMessages = messages.where((m) => !existingIds.contains(m.id)).toList();

        print('LoadMore: After deduplication: ${newMessages.length} new messages');

        final updatedMessages = [...state.messages, ...newMessages];

        emit(state.copyWith(
          status: ChatStatus.success,
          messages: updatedMessages,
          hasMore: messages.length >= 50,
          // ИСПРАВЛЕНО: обновляем oldestTimestamp только если есть новые сообщения
          oldestTimestamp: newMessages.isNotEmpty
              ? newMessages.last.createdAt
              : state.oldestTimestamp,
        ));
      },
    );
  }

  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(state.copyWith(status: ChatStatus.sending, clearError: true));

    final result = await chatRepository.sendMessage(
      content: event.content,
      imageFile: event.imageFile,
      videoFile: event.videoFile,
      replyTo: event.replyTo,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: failure.message,
      )),
          (message) {
        // Message will be added via socket event
        emit(state.copyWith(
          status: ChatStatus.success,
          clearReplyingTo: true,
        ));
      },
    );
  }

  Future<void> _onEditMessage(
      EditMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(state.copyWith(status: ChatStatus.editing, clearError: true));

    final result = await chatRepository.editMessage(
      messageId: event.messageId,
      content: event.content,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: failure.message,
      )),
          (message) {
        // Message will be updated via socket event
        emit(state.copyWith(status: ChatStatus.success));
      },
    );
  }

  Future<void> _onDeleteMessage(
      DeleteMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(state.copyWith(status: ChatStatus.deleting, clearError: true));

    final result = await chatRepository.deleteMessage(event.messageId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: failure.message,
      )),
          (_) {
        // Message will be removed via socket event
        emit(state.copyWith(status: ChatStatus.success));
      },
    );
  }

  Future<void> _onConnectSocket(
      ConnectSocketEvent event,
      Emitter<ChatState> emit,
      ) async {
    await socketService.connect(event.token);
  }

  Future<void> _onDisconnectSocket(
      DisconnectSocketEvent event,
      Emitter<ChatState> emit,
      ) async {
    socketService.disconnect();
    emit(state.copyWith(isSocketConnected: false));
  }

  void _onNewMessageReceived(
      NewMessageReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    // Check if message already exists
    final messageExists = state.messages.any((m) => m.id == event.message.id);

    if (!messageExists) {
      final updatedMessages = [event.message, ...state.messages];
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  void _onMessageEditedReceived(
      MessageEditedReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    final messageIndex = state.messages.indexWhere((m) => m.id == event.message.id);

    if (messageIndex != -1) {
      final updatedMessages = List<MessageModel>.from(state.messages);
      updatedMessages[messageIndex] = event.message;
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  void _onMessageDeletedReceived(
      MessageDeletedReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    final updatedMessages = state.messages
        .map((m) => m.id == event.messageId
        ? m.copyWith(isDeleted: true, content: 'Message deleted')
        : m)
        .toList();

    emit(state.copyWith(messages: updatedMessages));
  }

  void _onStartTyping(
      StartTypingEvent event,
      Emitter<ChatState> emit,
      ) {
    socketService.startTyping();

    // Auto-stop typing after 5 seconds
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 5), () {
      add(StopTypingEvent());
    });
  }

  void _onStopTyping(
      StopTypingEvent event,
      Emitter<ChatState> emit,
      ) {
    socketService.stopTyping();
    _typingTimer?.cancel();
  }

  void _onUserTypingReceived(
      UserTypingReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    final updatedTypingUsers = Map<String, bool>.from(state.typingUsers);
    updatedTypingUsers[event.userId] = true;
    emit(state.copyWith(typingUsers: updatedTypingUsers));
  }

  void _onUserStoppedTypingReceived(
      UserStoppedTypingReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    final updatedTypingUsers = Map<String, bool>.from(state.typingUsers);
    updatedTypingUsers.remove(event.userId);
    emit(state.copyWith(typingUsers: updatedTypingUsers));
  }

  void _onGetOnlineUsers(
      GetOnlineUsersEvent event,
      Emitter<ChatState> emit,
      ) {
    socketService.getOnlineUsers();
  }

  void _onOnlineUsersReceived(
      OnlineUsersReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(onlineUsers: event.users));
  }

  void _onUserJoinedReceived(
      UserJoinedReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    final userExists = state.onlineUsers.any((u) => u.userId == event.user.userId);

    if (!userExists) {
      final updatedUsers = [...state.onlineUsers, event.user];
      emit(state.copyWith(onlineUsers: updatedUsers));
    }
  }

  void _onUserLeftReceived(
      UserLeftReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    final updatedUsers = state.onlineUsers
        .where((u) => u.userId != event.userId)
        .toList();

    emit(state.copyWith(onlineUsers: updatedUsers));
  }

  void _onMarkMessagesAsRead(
      MarkMessagesAsReadEvent event,
      Emitter<ChatState> emit,
      ) {
    socketService.markMessagesAsRead(event.lastReadMessageId);
  }

  void _onMessagesReadReceived(
      MessagesReadReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    // Handle read receipts if needed
    // You can update message models to show read status
  }

  Future<void> _onLoadChatInfo(
      LoadChatInfoEvent event,
      Emitter<ChatState> emit,
      ) async {
    final result = await chatRepository.getChatInfo();

    result.fold(
          (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
          (info) => emit(state.copyWith(chatInfo: info)),
    );
  }

  void _onConnectionStatusChanged(
      ConnectionStatusChangedEvent event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(isSocketConnected: event.isConnected));
  }

  @override
  Future<void> close() {
    _newMessageSubscription?.cancel();
    _messageEditedSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    _userJoinedSubscription?.cancel();
    _userLeftSubscription?.cancel();
    _userTypingSubscription?.cancel();
    _userStoppedTypingSubscription?.cancel();
    _onlineUsersSubscription?.cancel();
    _messagesReadSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _typingTimer?.cancel();
    socketService.dispose();
    return super.close();
  }
}