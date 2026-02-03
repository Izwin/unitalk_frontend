import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:unitalk/core/api/api_client.dart';
import 'package:unitalk/core/services/activity_log_service.dart';
import 'package:unitalk/core/services/chat_socker_service.dart';
import 'package:unitalk/core/services/post_syns_service.dart';
import 'package:unitalk/core/theme/bloc/theme_bloc.dart';
import 'package:unitalk/core/theme/data/repository/theme_repository_impl.dart';
import 'package:unitalk/core/theme/domain/repository/theme_repository.dart';
import 'package:unitalk/features/about_config/data/datasource/about_config_remote_datasource.dart';
import 'package:unitalk/features/about_config/data/repository/about_config_repository_impl.dart';
import 'package:unitalk/features/about_config/domain/repository/about_config_repository.dart';
import 'package:unitalk/features/about_config/presentation/bloc/about_config_bloc.dart';
import 'package:unitalk/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:unitalk/features/auth/data/datasource/user_remote_datasource.dart';
import 'package:unitalk/features/auth/data/datasource/verefication_remote_datasource.dart';
import 'package:unitalk/features/auth/data/repository/auth_repository_impl.dart';
import 'package:unitalk/features/auth/data/repository/user_repository_impl.dart';
import 'package:unitalk/features/auth/data/repository/verification_repository_impl.dart';
import 'package:unitalk/features/auth/domain/repository/auth_repository.dart';
import 'package:unitalk/features/auth/domain/repository/user_repository.dart';
import 'package:unitalk/features/auth/domain/repository/verification_repository.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/block/data/datasource/block_remote_datasource.dart';
import 'package:unitalk/features/block/data/repository/block_repository_impl.dart';
import 'package:unitalk/features/block/domain/repository/block_repository.dart';
import 'package:unitalk/features/block/presentation/bloc/block_bloc.dart';
import 'package:unitalk/features/chat/data/datasource/chat_remote_datasource.dart';
import 'package:unitalk/features/chat/data/repository/chat_repository_impl.dart';
import 'package:unitalk/features/chat/domain/repository/chat_repository.dart';
import 'package:unitalk/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:unitalk/features/feed/data/datasource/announcement_remote_datasource.dart';
import 'package:unitalk/features/feed/data/datasource/comment_remote_datasource.dart';
import 'package:unitalk/features/feed/data/datasource/like_remote_datasource.dart';
import 'package:unitalk/features/feed/data/datasource/post_remote_datasource.dart';
import 'package:unitalk/features/feed/data/repository/announcement_repository_impl.dart';
import 'package:unitalk/features/feed/data/repository/comment_repository_impl.dart';
import 'package:unitalk/features/feed/data/repository/like_repository_impl.dart';
import 'package:unitalk/features/feed/data/repository/post_repository_impl.dart';
import 'package:unitalk/features/feed/domain/repository/announcement_repository.dart';
import 'package:unitalk/features/feed/domain/repository/comment_repository.dart';
import 'package:unitalk/features/feed/domain/repository/like_repository.dart';
import 'package:unitalk/features/feed/domain/repository/posts_repository.dart';
import 'package:unitalk/features/feed/presentation/bloc/announcement/announcement_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment_likers/comment_likers_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/like/like_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post_likers/post_likers_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:unitalk/features/friendship/data/datasource/friendship_remote_datasource.dart';
import 'package:unitalk/features/friendship/domain/repository/friendship_repository.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_bloc.dart';
import 'package:unitalk/features/notifications/data/notifcation_remote_datasource.dart';
import 'package:unitalk/features/notifications/data/notifcation_repository_impl.dart';
import 'package:unitalk/features/notifications/domain/notifcation_repository.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:unitalk/features/report/data/repository/report_repository_impl.dart';
import 'package:unitalk/features/report/domain/repository/report_repository.dart';
import 'package:unitalk/features/report/presentation/bloc/report_bloc.dart';
import 'package:unitalk/features/search/data/datasource/user_search_remote_datasource.dart';
import 'package:unitalk/features/search/data/repository/user_search_repository_impl.dart';
import 'package:unitalk/features/search/domain/repository/user_search_repository.dart';
import 'package:unitalk/features/search/presentation/bloc/user_search_bloc.dart';
import 'package:unitalk/features/support/data/datasource/support_remote_datasource.dart';
import 'package:unitalk/features/support/data/repository/support_repository_impl.dart';
import 'package:unitalk/features/support/domain/repository/support_repository.dart';
import 'package:unitalk/features/support/presentation/bloc/support_bloc.dart';
import 'package:unitalk/features/university/data/data_sources/university_remote_datasource.dart';
import 'package:unitalk/features/university/data/repositories/university_repository_impl.dart';
import 'package:unitalk/features/university/domain/repositories/university_repository.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';
import 'package:unitalk/l10n/data/repository/local_repository_impl.dart';
import 'package:unitalk/l10n/domain/repository/locale_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/friendship/data/repository/friendship_repository_impl.dart';
import '../../features/report/data/datasource/report_remote_datasource.dart' show ReportRemoteDataSource;

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Firebase Services


  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);


  sl.registerLazySingleton(() => PostSyncService());
  sl.registerLazySingleton<ActivityLoggerService>(
        () => ActivityLoggerService( sl(instanceName: 'dioAuth')),
  );

  sl.registerLazySingleton(() => ChatSocketService(baseUrl: 'http://35.198.109.53'));

  // Dio clients
  sl.registerLazySingleton<Dio>(
        () => DioClient.createDio(withAuthInterceptor: false),
    instanceName: 'dioPublic',
  );

  sl.registerLazySingleton<Dio>(
        () => DioClient.createDio(
      withAuthInterceptor: true,
      firebaseAuth: sl<FirebaseAuth>(),
    ),
    instanceName: 'dioAuth',
  );

  // DataSources - Auth (без токена)
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      dio: sl(instanceName: 'dioPublic'),
    ),
  );

  // DataSources - User (с токеном)
  sl.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSource(
      dio: sl(instanceName: 'dioAuth'),
    ),
  );

  sl.registerLazySingleton<UniversityRemoteDataSource>(
        () => UniversityRemoteDataSource(
      dio: sl(instanceName: 'dioAuth'),
      firebaseAuth: sl(),
    ),
  );

  sl.registerLazySingleton<ChatRemoteDataSource>(
        () => ChatRemoteDataSource(
     dio: sl(instanceName: 'dioAuth'))
  );

  sl.registerLazySingleton<PostRemoteDataSource>(
        () => PostRemoteDataSource(dio:  sl(instanceName: 'dioAuth'),
    ),
  );
  sl.registerLazySingleton<FriendshipRemoteDataSource>(
        () => FriendshipRemoteDataSource(dio: sl(instanceName: 'dioAuth')),
  );

  // ДОБАВЬТЕ ПОСЛЕ других Repositories:

  sl.registerLazySingleton<FriendshipRepository>(
        () => FriendshipRepositoryImpl(sl()),
  );

  // ДОБАВЬТЕ ПОСЛЕ других Blocs:

  sl.registerFactory(() => FriendshipBloc(repository: sl()));
  sl.registerLazySingleton<LikeRemoteDataSource>(
        () => LikeRemoteDataSource(dio:  sl(instanceName: 'dioAuth'),
    ),
  );
  sl.registerLazySingleton<AboutConfigRemoteDataSource>(
        () => AboutConfigRemoteDataSource(dio: sl(instanceName: 'dioAuth')),
  );

  sl.registerLazySingleton<AboutConfigRepository>(
        () => AboutConfigRepositoryImpl(sl<AboutConfigRemoteDataSource>()),
  );

  sl.registerFactory<AboutConfigBloc>(
        () => AboutConfigBloc(repository: sl<AboutConfigRepository>()),
  );

  sl.registerLazySingleton<CommentRemoteDataSource>(
        () => CommentRemoteDataSource(dio:  sl(instanceName: 'dioAuth'),
    ),
  );

  sl.registerLazySingleton<VerificationRemoteDataSource>(
        () => VerificationRemoteDataSource(dio:  sl(instanceName: 'dioAuth',)
    ),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
        () => NotificationRemoteDataSource(dio:  sl(instanceName: 'dioAuth',)
    ),
  );

  sl.registerLazySingleton<UserSearchRemoteDataSource>(
        () => UserSearchRemoteDataSource(dio:  sl(instanceName: 'dioAuth',)
    ),
  );

  sl.registerLazySingleton<SupportRemoteDataSource>(
        () => SupportRemoteDataSource(dio:  sl(instanceName: 'dioAuth',)
    ),
  );

  sl.registerLazySingleton<AnnouncementRemoteDataSource>(
        () => AnnouncementRemoteDataSource(dio:  sl(instanceName: 'dioAuth',)
    ),
  );
  // Moderation - Block
  sl.registerFactory(() => BlockRemoteDataSource(dio:  sl(instanceName: 'dioAuth',)));
  sl.registerFactory<BlockRepository>(() => BlockRepositoryImpl(sl()));
  sl.registerFactory(() => BlockBloc(blockRepository: sl()));

// Moderation - Report
  sl.registerFactory(() => ReportRemoteDataSource(dio:  sl(instanceName: 'dioAuth',)));
  sl.registerFactory<ReportRepository>(() => ReportRepositoryImpl(sl()));
  sl.registerFactory(() => ReportBloc(reportRepository: sl()));

  // Repositories - Auth
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl()),
  );

  // Repositories - User
  sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(sl()),
  );

  // Repositories - Others
  sl.registerLazySingleton<ThemeRepository>(
        () => ThemeRepositoryImpl(),
  );
  sl.registerLazySingleton<ChatRepository>(
        () => ChatRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<LocaleRepository>(
        () => LocaleRepositoryImpl(),
  );

  sl.registerLazySingleton<UniversityRepository>(
        () => UniversityRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<PostRepository>(
        () => PostRepositoryImpl(sl()),
  );


  sl.registerLazySingleton<LikeRepository>(
        () => LikeRepositoryImpl(sl())
  );

  sl.registerLazySingleton<CommentRepository>(
          () => CommentRepositoryImpl(sl())
  );
  sl.registerLazySingleton<VerificationRepository>(
          () => VerificationRepositoryImpl(sl())
  );

  sl.registerLazySingleton<NotificationRepository>(
          () => NotificationRepositoryImpl(sl())
  );


  sl.registerLazySingleton<UserSearchRepository>(
          () => UserSearchRepositoryImpl(sl())
  );

  sl.registerLazySingleton<SupportRepository>(
          () => SupportRepositoryImpl(sl())
  );


  sl.registerLazySingleton<AnnouncementRepository>(
          () => AnnouncementRepositoryImpl(sl())
  );



  // Blocs / Cubits
  sl.registerSingleton( AuthBloc(
    authRepository: sl(),
    userRepository: sl(),
    verificationRepository: sl()
  ));
  sl.registerFactory(() => ThemeBloc(sl()));
  sl.registerFactory(() => LocaleCubit(sl(),sl()));
  sl.registerFactory(() => UniversityBloc(sl()));
  sl.registerFactory(() => SupportBloc(supportRepository: sl()));
  sl.registerFactory(() => LikeBloc(likeRepository: sl()));
  sl.registerFactory(() => PostLikersBloc(repository: sl()));
  sl.registerFactory(() => CommentLikersBloc(repository: sl()));
  sl.registerFactory<ChatBloc>(
        () => ChatBloc( chatRepository: sl<ChatRepository>(),socketService: sl()),
  );
  sl.registerFactory<PostBloc>(
        () => PostBloc(postRepository: sl(),likeRepository: sl(),postSyncService: sl()),
  );

  sl.registerFactory<CommentBloc>(
        () => CommentBloc(commentRepository: sl(), postSyncService: sl(),commentLikeRepository: sl()),
  );

  sl.registerFactory<UserProfileBloc>(
        () => UserProfileBloc(userRepository: sl()),
  );

  sl.registerFactory<NotificationBloc>(
        () => NotificationBloc(notificationRepository: sl()),
  );

  sl.registerFactory<UserSearchBloc>(
        () => UserSearchBloc(repository: sl()),
  );

  sl.registerFactory<RepliesBloc>(
        () => RepliesBloc(commentRepository: sl(),postSyncService: sl(),commentLikeRepository: sl()),
  );

  sl.registerFactory<AnnouncementBloc>(
        () => AnnouncementBloc(announcementRepository: sl()),
  );

}