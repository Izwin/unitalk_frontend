import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/di/service_locator.dart';
import 'package:unitalk/core/ui/common/fullscreen_image_viewer.dart';
import 'package:unitalk/core/ui/common/fullscreen_video_player.dart';
import 'package:unitalk/features/about_config/presentation/bloc/about_config_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/auth/presentation/page/about_page.dart';
import 'package:unitalk/features/auth/presentation/page/auth_page.dart';
import 'package:unitalk/features/auth/presentation/page/complete_profile_page.dart';
import 'package:unitalk/features/auth/presentation/page/delete_account_page.dart';
import 'package:unitalk/features/auth/presentation/page/privacy_policy_page.dart';
import 'package:unitalk/features/auth/presentation/profile_page.dart';
import 'package:unitalk/features/auth/presentation/edit_profile_page.dart';
import 'package:unitalk/features/auth/presentation/verification_page.dart';
import 'package:unitalk/features/chat/presentation/page/chat_participants_page.dart';
import 'package:unitalk/features/chat/presentation/page/faculty_chat_screen.dart';
import 'package:unitalk/features/feed/presentation/bloc/announcement/announcement_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment_likers/comment_likers_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post_likers/post_likers_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:unitalk/features/feed/presentation/page/comment_likers_page.dart';
import 'package:unitalk/features/feed/presentation/page/create_post_page.dart';
import 'package:unitalk/features/feed/presentation/page/feed_page.dart';
import 'package:unitalk/features/feed/presentation/page/other_profile_screen.dart';
import 'package:unitalk/features/feed/presentation/page/post_detail_page.dart';
import 'package:unitalk/features/feed/presentation/page/post_likers_page.dart';
import 'package:unitalk/features/friendship/presentation/pages/friend_requests_page.dart';
import 'package:unitalk/features/friendship/presentation/pages/friends_list_page.dart';
import 'package:unitalk/features/friendship/presentation/pages/friends_page.dart';
import 'package:unitalk/features/home/home_page.dart';
import 'package:unitalk/features/notifications/presentation/page/notification_settings_page.dart';
import 'package:unitalk/features/notifications/presentation/page/notifications_page.dart';
import 'package:unitalk/features/report/presentation/page/blocked_users_page.dart';
import 'package:unitalk/features/report/presentation/page/my_reports_page.dart';
import 'package:unitalk/features/search/presentation/page/user_search_page.dart';
import 'package:unitalk/features/support/presentation/page/create_support_message_page.dart';
import 'package:unitalk/features/support/presentation/page/support_help_page.dart';
import 'package:unitalk/features/support/presentation/page/support_message_details_page.dart';
import 'package:unitalk/splash_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final feedPageKey = GlobalKey<FeedPageState>();

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
  navigatorKey: GlobalKey<NavigatorState>(),

  routes: [
    // === SPLASH & AUTH ===
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const IntroductionPage(),
    ),
    GoRoute(
      path: '/introduction',
      name: 'introduction',
      builder: (context, state) => const IntroductionPage(),
    ),
    GoRoute(
      path: '/profile-setup/name',
      name: 'profile-setup-name',
      builder: (context, state) => const CompleteProfilePage(),
    ),
    GoRoute(
      path: '/profile-verification',
      builder: (context, state) => const VerificationPage(),
    ),

    // === MAIN APP WITH BOTTOM NAV ===
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // === FEED BRANCH ===
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/feed',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: BlocProvider(
                  create: (context) => sl<AnnouncementBloc>(),
                  child: BlocProvider(
                    create: (context) => sl<PostBloc>(),
                    child: FeedPage(key: feedPageKey),
                  ),
                ),
              ),
            ),
          ],
        ),

        // === SEARCH BRANCH ===
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const UserSearchPage(),
              ),
            ),
          ],
        ),

        // === CHAT BRANCH ===
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              pageBuilder: (context, state) =>
                  NoTransitionPage(key: state.pageKey, child: const ChatPage()),
            ),
          ],
        ),

        // === PROFILE BRANCH ===
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: BlocProvider(
                  create: (context) => sl<PostBloc>(),
                  child: const ProfilePage(),
                ),
              ),
            ),
          ],
        ),
      ],
    ),

    // === STANDALONE ROUTES ===

    // Notifications
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsPage(),
    ),

    // Posts
    GoRoute(
      path: '/create-post',
      builder: (context, state) => BlocProvider(
        create: (context) => sl<PostBloc>(),
        child: CreatePostPage(),
      ),
    ),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final postId = state.pathParameters['id']!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<CommentBloc>()),
            BlocProvider(create: (context) => sl<PostBloc>()),
          ],
          child: PostDetailPage(postId: postId),
        );
      },
    ),
    GoRoute(
      path: '/post/:id/likers',
      builder: (context, state) {
        final postId = state.pathParameters['id']!;
        return BlocProvider(
          create: (context) => sl<PostLikersBloc>(),
          child: PostLikersPage(postId: postId),
        );
      },
    ),
    GoRoute(
      path: '/comment/:id/likers',
      builder: (context, state) {
        final commentId = state.pathParameters['id']!;
        return BlocProvider(
          create: (context) => sl<CommentLikersBloc>(),
          child: CommentLikersPage(commentId: commentId),
        );
      },
    ),

    GoRoute(
      path: '/blocked-users',
      builder: (context, state) => const BlockedUsersPage(),
    ),
    GoRoute(
      path: '/my-reports',
      builder: (context, state) => const MyReportsPage(),
    ),

    // ─── Users ──────────────────────────────────────────────────
    GoRoute(
      path: '/user/:id',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<UserProfileBloc>()),
            BlocProvider(create: (context) => sl<PostBloc>()),
          ],
          child: OtherUserProfileScreen(userId: userId),
        );
      },
    ),
    // ─── Друзья другого пользователя ──────────────────────────
    GoRoute(
      path: '/user/:id/friends',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        return FriendsListPage(userId: userId);
      },
    ),

    // Profile
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),

    GoRoute(
      path: '/chat/participants',
      builder: (context, state) => const ChatParticipantsPage(),
    ),

    // Support
    GoRoute(
      path: '/support',
      builder: (context, state) => const HelpSupportPage(),
    ),
    GoRoute(
      path: '/support/create',
      builder: (context, state) => const CreateSupportMessagePage(),
    ),
    GoRoute(
      path: '/support/:id',
      builder: (context, state) {
        final messageId = state.pathParameters['id']!;
        return SupportMessageDetailsPage(messageId: messageId);
      },
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => PrivacyPolicyPage(),
    ),
    GoRoute(
      path: '/terms-of-use',
      builder: (context, state) => TermsOfUsePage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => BlocProvider(
        create: (context) => sl<AboutConfigBloc>(),
        child: const AboutPage(),
      ),
    ),
    GoRoute(path: '/delete', builder: (context, state) => DeleteAccountPage()),

    // ─── Friendship ───────────────────────────────────────────
    // В вашем router.dart

    GoRoute(
      path: '/friends',
      builder: (context, state) => const FriendsPage(),
    ),
    GoRoute(
      path: '/user/:userId/friends',
      builder: (context, state) => FriendsPage(
        userId: state.pathParameters['userId'],
      ),
    ),


    // Media fullscreen
    GoRoute(
      path: '/video/:videoUrl',
      name: 'fullscreen_video',
      builder: (context, state) {
        final videoUrl = Uri.decodeComponent(state.pathParameters['videoUrl']!);
        final autoPlay = state.uri.queryParameters['autoPlay'] == 'true';
        return FullscreenVideoPlayer(videoUrl: videoUrl, autoPlay: autoPlay);
      },
    ),
    GoRoute(
      path: '/image/:imageUrl',
      name: 'fullscreen_image',
      builder: (context, state) {
        final imageUrl = Uri.decodeComponent(state.pathParameters['imageUrl']!);
        return FullscreenImageViewer(imageUrl: imageUrl);
      },
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Navigation Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(state.error.toString()),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/feed'),
            child: const Text('Go to Feed'),
          ),
        ],
      ),
    ),
  ),
);