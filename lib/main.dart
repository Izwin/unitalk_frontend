import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badge/flutter_app_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/di/service_locator.dart';
import 'package:unitalk/core/router/app_router.dart' as AppRouter;
import 'package:unitalk/core/theme/app_theme.dart';
import 'package:unitalk/core/theme/bloc/theme_bloc.dart';
import 'package:unitalk/core/theme/bloc/theme_event.dart';
import 'package:unitalk/core/theme/bloc/theme_state.dart';
import 'package:unitalk/core/theme/domain/entity/app_theme_mode.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/block/presentation/bloc/block_bloc.dart';
import 'package:unitalk/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_event.dart';
import 'package:unitalk/features/report/presentation/bloc/report_bloc.dart';
import 'package:unitalk/features/search/presentation/bloc/user_search_bloc.dart';
import 'package:unitalk/features/support/presentation/bloc/support_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_event.dart';
import 'package:unitalk/firebase_options.dart';
import 'package:unitalk/l10n/app_localizations.dart' show AppLocalizations;
import 'package:unitalk/l10n/bloc/locale_cubit.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterAppBadge.count(0);

  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final NotificationBloc _notificationBloc;
  late final ChatBloc _chatBloc;
  late final AuthBloc _authBloc;
  late final LocaleCubit _localeCubit;
  late final GoRouter _router;

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessagesSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  bool _hasInitializedNotifications = false;

  @override
  void initState() {
    super.initState();
    _notificationBloc = sl<NotificationBloc>();
    _chatBloc = sl<ChatBloc>();
    _authBloc = sl<AuthBloc>()..add(GetCurrentUserEvent());
    _localeCubit = sl<LocaleCubit>()..loadLocale();
    _router = AppRouter.router;

    _setupFCM();
    _setupNotificationHandlers();
    _listenToAuth();
  }

  void _setupFCM() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && _authBloc.state.status == AuthStatus.authenticated) {
        _notificationBloc.add(SaveFcmTokenEvent(token));
      }

      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((newToken) {
            if (_authBloc.state.status == AuthStatus.authenticated) {
              _notificationBloc.add(SaveFcmTokenEvent(newToken));
            }
          });
    }
  }

  void _setupNotificationHandlers() {
    // Foreground notifications
    _foregroundMessagesSubscription = FirebaseMessaging.onMessage.listen((
      message,
    ) {
      _notificationBloc.add(HandleIncomingNotificationEvent(message.data));

      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Background notification taps
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      _navigateFromNotification(message);
    });

    // Local notification initialization
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _router.go('/notifications');
        }
      },
    );
  }

  void _showLocalNotification(RemoteMessage message) {
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          message.data['type'] == 'new_chat_message' ? 'chat' : 'default',
          message.data['type'] == 'new_chat_message' ? 'Chat' : 'Default',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['notificationId'],
    );
  }

  void _navigateFromNotification(RemoteMessage message) {
    final route = _getRouteFromNotification(message);
    if (route != null) {
      _router.push(route);
    }
  }

  String? _getRouteFromNotification(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'new_post':
      case 'new_comment':
      case 'new_like':
      case 'comment_reply':
      case 'mention':
        if (data['postId'] != null) {
          return '/post/${data['postId']}';
        }
        break;
      case 'new_chat_message':
      case 'chat_mention':
        return '/chat';
      default:
        return '/notifications';
    }
    return null;
  }

  void _listenToAuth() {
    _authSubscription = _authBloc.stream.listen((state) {
      if (state.status == AuthStatus.authenticated) {
        _onUserAuthenticated(state);
      } else if (state.status == AuthStatus.unauthenticated ||
          state.status == AuthStatus.logout) {
        _onUserUnauthenticated();
      }
    });

    if (_authBloc.state.status == AuthStatus.authenticated) {
      _onUserAuthenticated(_authBloc.state);
    }
  }

  void _onUserAuthenticated(AuthState state) async {
    if (_hasInitializedNotifications) return;
    _hasInitializedNotifications = true;

    final isFirstLogin = _isFirstLogin(state.user);

    await _localeCubit.syncWithUser(
      userLanguage: state.user?.language,
      isFirstLogin: isFirstLogin,
    );

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _notificationBloc.add(SaveFcmTokenEvent(token));
    }

    _notificationBloc.add(GetNotificationSettingsEvent());
    _notificationBloc.add(GetNotificationsEvent());
  }

  bool _isFirstLogin(dynamic user) {
    return user == null ||
        user.language == null ||
        user.language.isEmpty ||
        !user.isProfileComplete;
  }

  void _onUserUnauthenticated() {
    _hasInitializedNotifications = false;
    _notificationBloc.add(RemoveFcmTokenEvent());
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _foregroundMessagesSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();

    _notificationBloc.close();
    _authBloc.close();
    _localeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => sl<ThemeBloc>()..add(LoadTheme())),
        BlocProvider(
          create: (_) => sl<UniversityBloc>()..add(LoadUniversitiesEvent()),
        ),
        BlocProvider.value(value: _localeCubit),
        BlocProvider.value(value: _chatBloc),
        BlocProvider(create: (_) => sl<UserSearchBloc>()),
        BlocProvider(create: (_) => sl<SupportBloc>()),
        BlocProvider.value(value: _notificationBloc),
        BlocProvider(create: (_) => sl<BlockBloc>()),
        BlocProvider(create: (_) => sl<ReportBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if(state.status == AuthStatus.logout){
                _router.go('/auth');
              }
              if(state.status == AuthStatus.unauthenticated){
                if(_router.state.matchedLocation != '/auth' && !_router.state.matchedLocation.startsWith('/profile-setup')){
                  _router.go('/auth');
                }
              }
              print('asada ${state.status}');
            },
            child: BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp.router(
                  title: 'UniTalky',
                  debugShowCheckedModeBanner: false,
                  darkTheme: AppTheme.darkTheme,
                  theme: AppTheme.lightTheme,
                  themeMode: themeState.themeMode == AppThemeMode.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  locale: locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('az'),
                    Locale('ru'),
                  ],
                  routerConfig: _router,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
