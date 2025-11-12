import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/theme/bloc/theme_bloc.dart';
import 'package:unitalk/core/theme/bloc/theme_event.dart';
import 'package:unitalk/core/theme/bloc/theme_state.dart';
import 'package:unitalk/core/theme/domain/entity/app_theme_mode.dart';
import 'package:unitalk/core/utils/notifications_utils.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  // Читаем из dart-define, по умолчанию false
  static const bool _enableDemoMode = bool.fromEnvironment(
    'ENABLE_DEMO_MODE',
    defaultValue: false,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isIOS = Platform.isIOS;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if(state.status == AuthStatus.authenticated){
          final user = state.user;
          final message = await FirebaseMessaging.instance.getInitialMessage();

          if (user?.isProfileComplete == false) {
            context.go('/profile-setup/name');
            return;
          }
          if (message != null) {
            final route = message.getRouteFromNotification();
            if(route!=null){
              context.go(route);
            }
            return;
          }

          context.go('/feed');
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Верхняя панель с кнопками
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ThemeToggleButton(),
                    const SizedBox(width: 12),
                    _LanguageSelector(),
                  ],
                ),
              ),

              // Основной контент с Expanded
              Expanded(
                child: Column(
                  children: [
                    // Верхний спейсер
                    const Spacer(flex: 1),

                    // Заголовок
                    Text(
                      l10n.welcome,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 42,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const Spacer(flex: 2),

                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: SvgPicture.asset('assets/images/intro.svg'),
                      ),
                    ),

                    const Spacer(flex: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        l10n.introDescription,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),

              // Нижняя панель с кнопками
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    // Кнопка Google
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(SignInWithGoogleEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/google.svg',
                              height: 24,
                              width: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.g_mobiledata, size: 24);
                              },
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.continueWithGoogle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Кнопка Apple (только для iOS)
                    if (isIOS) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              SignInWithAppleEvent(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.apple, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                l10n.continueWithApple,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // DEMO LOGIN - только если включен через dart-define
                    if (_enableDemoMode) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(SignInWithDemoEvent());
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.science_outlined,
                                size: 24,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Demo Account (Review Only)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Информационное сообщение для ревьюверов
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(
                            0.3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This demo account is only for store review purposes.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Текст о политике конфиденциальности
                    Text.rich(
                      TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: '${l10n.byContinuingYouAgree} '),
                          TextSpan(
                            text: l10n.privacyPolicy,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.push('/privacy-policy'),
                          ),
                          TextSpan(text: ' ${l10n.and} '),
                          TextSpan(
                            text: l10n.termsOfService,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.push('/terms-of-use'),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark =
            state.themeMode == AppThemeMode.dark ||
            (state.themeMode == AppThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return IconButton(
          onPressed: () {
            final newMode = isDark ? AppThemeMode.light : AppThemeMode.dark;
            context.read<ThemeBloc>().add(ChangeTheme(newMode));
          },
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return PopupMenuButton<Locale>(
          icon: Icon(
            Icons.language_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          itemBuilder: (context) => [
            _buildLanguageItem(context, const Locale('en'), 'English'),
            _buildLanguageItem(context, const Locale('ru'), 'Русский'),
            _buildLanguageItem(context, const Locale('az'), 'Azərbaycan'),
          ],
        );
      },
    );
  }

  PopupMenuItem<Locale> _buildLanguageItem(
    BuildContext context,
    Locale locale,
    String label,
  ) {
    final currentLocale = context.read<LocaleCubit>().state;
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return PopupMenuItem<Locale>(
      value: locale,
      onTap: () {
        context.read<LocaleCubit>().changeLocale(locale);
      },
      child: Row(
        children: [
          if (isSelected)
            Icon(
              Icons.check_rounded,
              size: 20,
              color: Theme.of(context).primaryColor,
            )
          else
            const SizedBox(width: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
