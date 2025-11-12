import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/router/app_router.dart';
import 'package:unitalk/core/utils/notifications_utils.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasNavigated = false;
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  void _navigateToNotificationTarget(String targetRoute) {
    context.go('/feed');
    Future.delayed(const Duration(milliseconds: 500), () {
      router.push(targetRoute);
    });
  }

  void _navigateTo(String route) {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      context.go(route);
    }
  }

  bool _isNetworkError(String? errorMessage) {
    if (errorMessage == null) return false;

    final networkErrorKeywords = [
      'network',
      'connection',
      'socket',
      'timeout',
      'failed host lookup',
      'no internet',
      'unreachable',
      'соединение', // Russian
      'bağlantı', // Turkish/Azerbaijani
    ];

    final lowerError = errorMessage.toLowerCase();
    return networkErrorKeywords.any((keyword) => lowerError.contains(keyword));
  }

  void _handleRetry() {
    setState(() {
      _showRetry = false;
    });
    context.read<AuthBloc>().add(GetCurrentUserEvent());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (_hasNavigated) return;

        if (state.status == AuthStatus.failure) {
          // Check if it's a network error
          if (_isNetworkError(state.errorMessage)) {
            setState(() {
              _showRetry = true;
            });
          } else {
            // For non-network errors (e.g., invalid token), go to auth
            _navigateTo('/auth');
          }
        } else if (state.status == AuthStatus.authenticated) {
          final user = state.user;

          if (user?.isProfileComplete == false) {
            _navigateTo('/profile-setup/name');
            return;
          }

          try {
            final message = await FirebaseMessaging.instance.getInitialMessage();
            if (message != null) {
              var initialNotificationRoute = message.getRouteFromNotification();
              if (initialNotificationRoute != null) {
                final route = initialNotificationRoute;
                initialNotificationRoute = null;
                _navigateToNotificationTarget(route);
                return;
              }
            }
          } catch (e) {
            debugPrint('Error checking initial notification: $e');
          }

          _navigateTo('/feed');
        } else if (state.status == AuthStatus.unauthenticated) {
          _navigateTo('/auth');
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFF089DBF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Image.asset(
                    'assets/icon/foreground.png',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (_showRetry) ...[
                const Icon(
                  Icons.wifi_off,
                  size: 48,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.noInternetConnection ?? 'No internet connection',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    l10n?.checkConnectionAndRetry ?? 'Please check your connection and try again',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    l10n?.retry ?? 'Retry',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else if (!_hasNavigated) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}