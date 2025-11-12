import 'dart:io';
import 'package:unitalk/features/chat/data/model/message_model.dart';

abstract class ChatEvent {}

class LoadParticipantsEvent extends ChatEvent {}


// Load initial messages
class LoadMessagesEvent extends ChatEvent {
  final int page;
  final int limit;
  final DateTime? before;

  LoadMessagesEvent({
    this.page = 1,
    this.limit = 50,
    this.before,
  });
}

// Load more messages (pagination)
class LoadMoreMessagesEvent extends ChatEvent {}

// Send message
class SendMessageEvent extends ChatEvent {
  final String content;
  final File? imageFile;
  final String? replyTo;

  SendMessageEvent({
    required this.content,
    this.imageFile,
    this.replyTo,
  });
}

// Edit message
class EditMessageEvent extends ChatEvent {
  final String messageId;
  final String content;

  EditMessageEvent({
    required this.messageId,
    required this.content,
  });
}

// Delete message
class DeleteMessageEvent extends ChatEvent {
  final String messageId;

  DeleteMessageEvent({required this.messageId});
}

// Socket events
class ConnectSocketEvent extends ChatEvent {
  final String token;

  ConnectSocketEvent({required this.token});
}

class DisconnectSocketEvent extends ChatEvent {}

class NewMessageReceivedEvent extends ChatEvent {
  final MessageModel message;

  NewMessageReceivedEvent({required this.message});
}

class MessageEditedReceivedEvent extends ChatEvent {
  final MessageModel message;

  MessageEditedReceivedEvent({required this.message});
}

class MessageDeletedReceivedEvent extends ChatEvent {
  final String messageId;

  MessageDeletedReceivedEvent({required this.messageId});
}

// Typing indicators
class StartTypingEvent extends ChatEvent {}

class StopTypingEvent extends ChatEvent {}

class UserTypingReceivedEvent extends ChatEvent {
  final String userId;
  final String firstName;
  final String lastName;

  UserTypingReceivedEvent({
    required this.userId,
    required this.firstName,
    required this.lastName,
  });
}

class UserStoppedTypingReceivedEvent extends ChatEvent {
  final String userId;

  UserStoppedTypingReceivedEvent({required this.userId});
}

// Online users
class GetOnlineUsersEvent extends ChatEvent {}

class OnlineUsersReceivedEvent extends ChatEvent {
  final List<OnlineUserModel> users;

  OnlineUsersReceivedEvent({required this.users});
}

class UserJoinedReceivedEvent extends ChatEvent {
  final OnlineUserModel user;

  UserJoinedReceivedEvent({required this.user});
}

class UserLeftReceivedEvent extends ChatEvent {
  final String userId;

  UserLeftReceivedEvent({required this.userId});
}

// Read receipts
class MarkMessagesAsReadEvent extends ChatEvent {
  final String lastReadMessageId;

  MarkMessagesAsReadEvent({required this.lastReadMessageId});
}

class MessagesReadReceivedEvent extends ChatEvent {
  final String userId;
  final String lastReadMessageId;
  final DateTime timestamp;

  MessagesReadReceivedEvent({
    required this.userId,
    required this.lastReadMessageId,
    required this.timestamp,
  });
}

// Load chat info
class LoadChatInfoEvent extends ChatEvent {}

// Connection status
class ConnectionStatusChangedEvent extends ChatEvent {
  final bool isConnected;

  ConnectionStatusChangedEvent({required this.isConnected});
}