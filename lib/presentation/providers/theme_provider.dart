import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테마 모드 상태
enum AppThemeMode {
  system,
  light,
  dark,
}

/// 테마 상태
class ThemeState {
  final AppThemeMode themeMode;
  final ThemeMode resolvedThemeMode;

  const ThemeState({
    required this.themeMode,
    required this.resolvedThemeMode,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    ThemeMode? resolvedThemeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      resolvedThemeMode: resolvedThemeMode ?? this.resolvedThemeMode,
    );
  }
}

/// 테마 Provider
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _themeModeKey = 'theme_mode';

  ThemeNotifier()
      : super(const ThemeState(
          themeMode: AppThemeMode.system,
          resolvedThemeMode: ThemeMode.system,
        )) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null) {
        final themeMode = AppThemeMode.values[themeModeIndex];
        state = state.copyWith(
          themeMode: themeMode,
          resolvedThemeMode: _resolveThemeMode(themeMode),
        );
      }
    } catch (e) {
      // 기본값 사용
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(
      themeMode: mode,
      resolvedThemeMode: _resolveThemeMode(mode),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      // 저장 실패 무시
    }
  }

  ThemeMode _resolveThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  void updateSystemBrightness(Brightness brightness) {
    if (state.themeMode == AppThemeMode.system) {
      state = state.copyWith(
        resolvedThemeMode:
            brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      );
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
