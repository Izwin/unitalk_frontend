import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/chat/data/model/message_model.dart';

enum ChatStatus {
  initial,
  loading,
  loadingMore,
  newMessage,
  success,
  failure,
  sending,
  editing,
  deleting,
}

class ChatState {
  final ChatStatus status;
  final List<MessageModel> messages;
  final ChatInfoModel? chatInfo;
  final List<OnlineUserModel> onlineUsers;
  final List<UserModel> participants;

  final Map<String, bool> typingUsers; // userId -> isTyping
  final bool hasMore;
  final DateTime? oldestTimestamp;
  final String? errorMessage;
  final bool isSocketConnected;
  final MessageModel? replyingTo;

  ChatState({
    required this.status,
    required this.messages,
    this.chatInfo,
    required this.onlineUsers,
    required this.typingUsers,
    required this.hasMore,
    this.oldestTimestamp,
    this.errorMessage,
    required this.participants,
    required this.isSocketConnected,
    this.replyingTo,
  });

  factory ChatState.initial() {
    return ChatState(
      status: ChatStatus.initial,
      messages: [],
      onlineUsers: [],
      participants: [],
      typingUsers: {},
      hasMore: true,
      isSocketConnected: false,
    );
  }

  ChatState copyWith({
    ChatStatus? status,
    List<MessageModel>? messages,
    ChatInfoModel? chatInfo,
    List<OnlineUserModel>? onlineUsers,
    Map<String, bool>? typingUsers,
    bool? hasMore,
    DateTime? oldestTimestamp,
    String? errorMessage,
    bool? isSocketConnected,
    MessageModel? replyingTo,
    List<UserModel>? participants,
    bool clearReplyingTo = false,
    bool clearError = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      chatInfo: chatInfo ?? this.chatInfo,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      typingUsers: typingUsers ?? this.typingUsers,
      hasMore: hasMore ?? this.hasMore,
      participants: participants ?? this.participants,
      oldestTimestamp: oldestTimestamp ?? this.oldestTimestamp,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
      replyingTo: clearReplyingTo ? null : (replyingTo ?? this.replyingTo),
    );
  }

  List<String> get currentlyTypingUsers {
    return typingUsers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
}