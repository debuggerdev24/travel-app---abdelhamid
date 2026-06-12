import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/theme/app_theme.dart';
import 'package:travel_app_abdelhamid/core/utils/pref_helper.dart';

enum ThemeModeOption { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeModeOption _themeModeOption = ThemeModeOption.system;

  ThemeModeOption get themeModeOption => _themeModeOption;

  ThemeMode get themeMode {
    switch (_themeModeOption) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  ThemeData get themeData {
    switch (_themeModeOption) {
      case ThemeModeOption.light:
        return AppTheme.light;
      case ThemeModeOption.dark:
        return AppTheme.dark;
      case ThemeModeOption.system:
        return AppTheme.light;
    }
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final savedThemeMode = PrefHelper.getThemeMode();
    if (savedThemeMode != null) {
      _themeModeOption = ThemeModeOption.values.firstWhere(
        (e) => e.name == savedThemeMode,
        orElse: () => ThemeModeOption.light,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    _themeModeOption = mode;
    await PrefHelper.saveThemeMode(mode.name);
    notifyListeners();
  }
}
