import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/theme/bloc/theme_bloc.dart';
import 'package:unitalk/core/theme/bloc/theme_event.dart';
import 'package:unitalk/core/theme/bloc/theme_state.dart';
import 'package:unitalk/core/theme/domain/entity/app_theme_mode.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_event.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n, theme),
            Divider(height: 1, thickness: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildThemeToggle(context, l10n, theme),
                  _buildLanguageOption(context, l10n),
                  _buildNotificationToggle(context, l10n, theme),

                  // ─── Раздел настроек ────────────────────
                  Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),
                  _buildTile(context, Icons.privacy_tip_outlined, l10n.privacySecurity, '/privacy-policy'),
                  _buildTile(context, Icons.description_outlined, l10n.termsOfUse, '/terms-of-use'),
                  _buildTile(context, Icons.help_outline, l10n.helpSupport, '/support'),
                  _buildTile(context, Icons.block_outlined, l10n.blockedUsers, '/blocked-users'),
                  _buildTile(context, Icons.flag_outlined, l10n.myReports, '/my-reports'),
                  _buildTile(context, Icons.info_outline, l10n.about, '/about'),

                  // ─── Опасная зона ───────────────────────
                  Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),
                  _buildTile(context, Icons.delete_outline, l10n.deleteAccount, '/delete',
                      color: theme.colorScheme.error),
                  _buildTile(context, Icons.logout, l10n.logout, null,
                      onTap: () => _showLogoutDialog(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.settings_outlined, size: 24, color: theme.colorScheme.onSurface),
          SizedBox(width: 12),
          Text(l10n.settings, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.themeMode == AppThemeMode.dark;
        return ListTile(
          leading: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, size: 22),
          title: Text(l10n.darkMode, style: TextStyle(fontSize: 15)),
          trailing: Switch(
            value: isDark,
            onChanged: (v) => context.read<ThemeBloc>().add(
                ChangeTheme(v ? AppThemeMode.dark : AppThemeMode.light)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          dense: true,
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return ListTile(
          leading: Icon(Icons.language_outlined, size: 22),
          title: Text(l10n.language, style: TextStyle(fontSize: 15)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getLanguageName(locale.languageCode),
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Icon(Icons.chevron_right, size: 20),
            ],
          ),
          onTap: () {
            _safePop(context);
            _showLanguageDialog(context);
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          dense: true,
        );
      },
    );
  }

  Widget _buildNotificationToggle(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final enabled = state.settings?.enabled ?? false;
        return ListTile(
          leading: Icon(Icons.notifications_outlined, size: 22),
          title: Text(l10n.notifications, style: TextStyle(fontSize: 15)),
          trailing: Switch(
            value: enabled,
            onChanged: (v) => context.read<NotificationBloc>().add(
                UpdateNotificationSettingsEvent(enabled: v)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          dense: true,
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String? route,
      {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, size: 22, color: color),
      title: Text(title, style: TextStyle(fontSize: 15, color: color)),
      trailing: route != null ? Icon(Icons.chevron_right, size: 20) : null,
      onTap: onTap ?? () {
        _safePop(context);
        if (route != null) context.push(route);
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      dense: true,
    );
  }

  String _getLanguageName(String code) =>
      {'en': 'English', 'ru': 'Русский', 'az': 'Azərbaycan'}[code] ?? 'English';

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.selectLanguage),
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangOption(ctx, Locale('en'), 'English'),
            _buildLangOption(ctx, Locale('ru'), 'Русский'),
            _buildLangOption(ctx, Locale('az'), 'Azərbaycan'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: Text(l10n.cancel)),
        ],
      ),
    );
  }

  Widget _buildLangOption(BuildContext ctx, Locale locale, String name) {
    final current = ctx.read<LocaleCubit>().state;
    final isSelected = locale.languageCode == current.languageCode;
    return ListTile(
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
      trailing: isSelected ? Icon(Icons.check, size: 20) : null,
      onTap: () {
        ctx.read<LocaleCubit>().changeLocale(locale);
        ctx.pop();
      },
      dense: true,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.areYouSureLogout),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              ctx.pop();
              ctx.read<AuthBloc>().add(SignOutEvent());
            },
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _safePop(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    }
  }
}