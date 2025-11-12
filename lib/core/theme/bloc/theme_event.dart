import 'package:unitalk/core/theme/domain/entity/app_theme_mode.dart';

abstract class ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class ChangeTheme extends ThemeEvent {
  final AppThemeMode themeMode;
  ChangeTheme(this.themeMode);
}
