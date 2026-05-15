import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_finance_ui/core/theme/theme_mode_controller.dart';

void main() {
  test('theme controller loads a persisted theme mode', () async {
    final _FakeThemeModeStorage storage = _FakeThemeModeStorage(
      initialThemeMode: ThemeMode.dark,
    );
    final AppThemeController controller = AppThemeController(storage: storage);

    await controller.loadThemeMode();

    expect(controller.themeMode, ThemeMode.dark);
    expect(controller.isDark, isTrue);
  });

  test('theme controller defaults to light when no theme is persisted', () async {
    final AppThemeController controller = AppThemeController(
      storage: _FakeThemeModeStorage(),
    );

    await controller.loadThemeMode();

    expect(controller.themeMode, ThemeMode.light);
  });

  test('theme controller saves updates', () {
    final _FakeThemeModeStorage storage = _FakeThemeModeStorage();
    final AppThemeController controller = AppThemeController(storage: storage);

    controller.setThemeMode(ThemeMode.system);

    expect(controller.themeMode, ThemeMode.system);
    expect(storage.savedThemeMode, ThemeMode.system);
  });

  test('theme toggle switches between light and dark and persists', () {
    final _FakeThemeModeStorage storage = _FakeThemeModeStorage();
    final AppThemeController controller = AppThemeController(storage: storage);

    controller.toggleThemeMode();

    expect(controller.themeMode, ThemeMode.dark);
    expect(storage.savedThemeMode, ThemeMode.dark);
  });
}

class _FakeThemeModeStorage implements AppThemeModeStorage {
  _FakeThemeModeStorage({ThemeMode? initialThemeMode})
    : _themeMode = initialThemeMode;

  ThemeMode? _themeMode;
  ThemeMode? savedThemeMode;

  @override
  Future<ThemeMode?> readThemeMode() async {
    return _themeMode;
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    savedThemeMode = themeMode;
    _themeMode = themeMode;
  }
}
