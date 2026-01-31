import 'dart:io';
import 'package:unitalk/core/services/post_syns_service.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';

abstract class PostEvent {
  const PostEvent();
}

class InitializeFeedEvent extends PostEvent {
  final UniversityModel university;

  const InitializeFeedEvent(this.university);
}

class ChangeUniversityEvent extends PostEvent {
  final UniversityModel university;

  const ChangeUniversityEvent(this.university);
}

class RefreshFeedEvent extends PostEvent {
  const RefreshFeedEvent();
}

class CreatePostEvent extends PostEvent {
  final String content;
  final bool isAnonymous;
  final File? mediaFile; // Изменено с imageFile на mediaFile

  const CreatePostEvent({
    required this.content,
    required this.isAnonymous,
    this.mediaFile,
  });
}

class GetPostsEvent extends PostEvent {
  final String? universityId;
  final String? authorId;
  final String sortBy;
  final String? sector;
  final String? facultyId;
  final int page;
  final int limit;

  const GetPostsEvent({
    this.universityId,
    this.authorId,
    this.sortBy = 'new',
    this.sector,
    this.facultyId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [
    universityId,
    authorId,
    sortBy,
    sector,
    facultyId,
    page,
    limit
  ];
}

class GetPostEvent extends PostEvent {
  final String postId;

  const GetPostEvent(this.postId);
}

class DeletePostEvent extends PostEvent {
  final String postId;

  const DeletePostEvent(this.postId);
}

class ToggleLikeEvent extends PostEvent {
  final String postId;

  const ToggleLikeEvent(this.postId);
}

class SyncPostUpdateEvent extends PostEvent {
  final PostUpdate update;

  const SyncPostUpdateEvent(this.update);
}