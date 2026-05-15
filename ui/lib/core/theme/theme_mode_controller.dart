import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AppThemeModeStorage {
  Future<ThemeMode?> readThemeMode();
  Future<void> saveThemeMode(ThemeMode themeMode);
}

class SecureAppThemeModeStorage implements AppThemeModeStorage {
  SecureAppThemeModeStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _themeModeKey = 'root_finance_theme_mode';

  final FlutterSecureStorage _storage;

  @override
  Future<ThemeMode?> readThemeMode() async {
    final String? raw = await _storage.read(key: _themeModeKey);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) {
    final String value = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return _storage.write(key: _themeModeKey, value: value);
  }
}

class AppThemeController extends ChangeNotifier {
  AppThemeController({
    AppThemeModeStorage? storage,
    ThemeMode initialThemeMode = ThemeMode.light,
  }) : _storage = storage ?? SecureAppThemeModeStorage(),
       _themeMode = initialThemeMode;

  final AppThemeModeStorage _storage;
  ThemeMode _themeMode;
  bool _disposed = false;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> loadThemeMode() async {
    final ThemeMode? storedThemeMode = await _storage.readThemeMode();
    if (_disposed || storedThemeMode == null || storedThemeMode == _themeMode) {
      return;
    }

    _themeMode = storedThemeMode;
    notifyListeners();
  }

  void toggleThemeMode() {
    setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();
    unawaited(_storage.saveThemeMode(themeMode));
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    super.key,
    required AppThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final AppThemeScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope not found in widget tree');
    return scope!.notifier!;
  }
}
