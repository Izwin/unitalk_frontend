import 'dart:async';
import 'package:unitalk/features/feed/data/model/post_model.dart';

enum PostUpdateType { like, comment, delete, edit, create }

class PostUpdate {
  final String postId;
  final PostUpdateType type;
  final PostModel? updatedPost;
  final int? newCommentsCount;
  final int? newLikesCount;
  final int? commentDelta; // <--- добавлено: изменение счётчика

  PostUpdate({
    required this.postId,
    required this.type,
    this.updatedPost,
    this.newCommentsCount,
    this.newLikesCount,
    this.commentDelta,
  });
}

class PostSyncService {
  final _controller = StreamController<PostUpdate>.broadcast();

  Stream<PostUpdate> get updates => _controller.stream;

  void notifyPostUpdated(PostUpdate update) {
    print(
      'PostSyncService: Broadcasting update - type: ${update.type}, postId: ${update.postId}',
    );
    _controller.add(update);
  }

  void notifyPostLiked(String postId, PostModel updatedPost) {
    _controller.add(PostUpdate(
      postId: postId,
      type: PostUpdateType.like,
      updatedPost: updatedPost,
      newLikesCount: updatedPost.likesCount,
    ));
  }

  /// Передаёт абсолютное значение количества комментариев (старый способ)
  void notifyPostCommented(String postId, int newCommentsCount) {
    print('PostSyncService: Post commented - postId: $postId, count: $newCommentsCount');
    _controller.add(PostUpdate(
      postId: postId,
      type: PostUpdateType.comment,
      newCommentsCount: newCommentsCount,
    ));
  }

  /// Новый способ: передаёт изменение счётчика (+1 или -1)
  void incrementPostComments(String postId, [int delta = 1]) {
    print('PostSyncService: Increment comments for $postId by $delta');
    _controller.add(PostUpdate(
      postId: postId,
      type: PostUpdateType.comment,
      commentDelta: delta,
    ));
  }

  void decrementPostComments(String postId, [int delta = 1]) {
    print('PostSyncService: Decrement comments for $postId by $delta');
    _controller.add(PostUpdate(
      postId: postId,
      type: PostUpdateType.comment,
      commentDelta: -delta,
    ));
  }

  void notifyPostDeleted(String postId) {
    _controller.add(PostUpdate(
      postId: postId,
      type: PostUpdateType.delete,
    ));
  }

  void dispose() {
    _controller.close();
  }
}
