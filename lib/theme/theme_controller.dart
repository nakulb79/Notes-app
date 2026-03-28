import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  static const String settingsBoxName = 'settingsBox';
  static const String themeModeKey = 'themeMode';

  final Box _settingsBox;

  ThemeController(this._settingsBox) : super(_readThemeMode(_settingsBox));

  static ThemeMode _readThemeMode(Box box) {
    final raw = box.get(themeModeKey, defaultValue: 'system') as String;
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;
    await _settingsBox.put(themeModeKey, _toStorage(mode));
  }

  String _toStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
