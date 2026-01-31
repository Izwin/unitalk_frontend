import 'package:firebase_messaging/firebase_messaging.dart';

extension NotificationsUtils on RemoteMessage{
  String? getRouteFromNotification() {
    final data = this.data;
    final type = data['type'];

    switch (type) {
      case 'new_post':
      case 'new_comment':
      case 'new_like':
      case 'comment_reply':
      case 'mention':
      case 'new_comment_like':
        final postId = data['postId'];
        return postId != null ? '/post/$postId' : null;

      case 'new_chat_message':
      case 'chat_mention':
        return '/chat';

      default:
        return '/notifications';
    }
  }

}

