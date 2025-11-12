import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:unitalk/features/chat/data/model/message_model.dart';

class ChatSocketService {
  IO.Socket? _socket;
  final String baseUrl;

  // Stream controllers
  final _newMessageController = StreamController<MessageModel>.broadcast();
  final _messageEditedController = StreamController<MessageModel>.broadcast();
  final _messageDeletedController = StreamController<Map<String, dynamic>>.broadcast();
  final _userJoinedController = StreamController<OnlineUserModel>.broadcast();
  final _userLeftController = StreamController<String>.broadcast();
  final _userTypingController = StreamController<Map<String, dynamic>>.broadcast();
  final _userStoppedTypingController = StreamController<String>.broadcast();
  final _onlineUsersController = StreamController<List<OnlineUserModel>>.broadcast();
  final _messagesReadController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Streams
  Stream<MessageModel> get newMessage => _newMessageController.stream;
  Stream<MessageModel> get messageEdited => _messageEditedController.stream;
  Stream<Map<String, dynamic>> get messageDeleted => _messageDeletedController.stream;
  Stream<OnlineUserModel> get userJoined => _userJoinedController.stream;
  Stream<String> get userLeft => _userLeftController.stream;
  Stream<Map<String, dynamic>> get userTyping => _userTypingController.stream;
  Stream<String> get userStoppedTyping => _userStoppedTypingController.stream;
  Stream<List<OnlineUserModel>> get onlineUsers => _onlineUsersController.stream;
  Stream<Map<String, dynamic>> get messagesRead => _messagesReadController.stream;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  ChatSocketService({required this.baseUrl});

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect(String token) async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _setupEventListeners();
    _socket!.connect();
  }

  void _setupEventListeners() {
    _socket!.onConnect((_) {
      print('Chat socket connected');
      _connectionStatusController.add(true);
      getOnlineUsers();
    });

    _socket!.onDisconnect((_) {
      print('Chat socket disconnected');
      _connectionStatusController.add(false);
    });

    _socket!.onConnectError((error) {
      print('Chat socket connection error: $error');
      _connectionStatusController.add(false);
    });

    _socket!.on('new_message', (data) {
      try {
        final message = MessageModel.fromJson(data as Map<String, dynamic>);
        _newMessageController.add(message);
      } catch (e) {
        print('Error parsing new message: $e');
      }
    });

    _socket!.on('message_edited', (data) {
      try {
        final message = MessageModel.fromJson(data as Map<String, dynamic>);
        _messageEditedController.add(message);
      } catch (e) {
        print('Error parsing edited message: $e');
      }
    });

    _socket!.on('message_deleted', (data) {
      _messageDeletedController.add(data as Map<String, dynamic>);
    });

    _socket!.on('user_joined', (data) {
      try {
        final user = OnlineUserModel.fromJson(data as Map<String, dynamic>);
        _userJoinedController.add(user);
      } catch (e) {
        print('Error parsing user joined: $e');
      }
    });

    _socket!.on('user_left', (data) {
      final userId = (data as Map<String, dynamic>)['userId'] as String;
      _userLeftController.add(userId);
    });

    _socket!.on('user_typing', (data) {
      _userTypingController.add(data as Map<String, dynamic>);
    });

    _socket!.on('user_stopped_typing', (data) {
      final userId = (data as Map<String, dynamic>)['userId'] as String;
      _userStoppedTypingController.add(userId);
    });

    _socket!.on('online_users', (data) {
      try {
        final users = (data as List)
            .map((u) => OnlineUserModel.fromJson(u as Map<String, dynamic>))
            .toList();
        _onlineUsersController.add(users);
      } catch (e) {
        print('Error parsing online users: $e');
      }
    });

    _socket!.on('messages_read_by_user', (data) {
      _messagesReadController.add(data as Map<String, dynamic>);
    });

    _socket!.on('error', (error) {
      print('Chat socket error: $error');
    });
  }

  void startTyping() {
    _socket?.emit('typing_start');
  }

  void stopTyping() {
    _socket?.emit('typing_stop');
  }

  void markMessagesAsRead(String lastReadMessageId) {
    _socket?.emit('messages_read', {'lastReadMessageId': lastReadMessageId});
  }

  void getOnlineUsers() {
    _socket?.emit('get_online_users');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _newMessageController.close();
    _messageEditedController.close();
    _messageDeletedController.close();
    _userJoinedController.close();
    _userLeftController.close();
    _userTypingController.close();
    _userStoppedTypingController.close();
    _onlineUsersController.close();
    _messagesReadController.close();
    _connectionStatusController.close();
  }
}