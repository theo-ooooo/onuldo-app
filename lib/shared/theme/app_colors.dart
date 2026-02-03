import 'package:flutter/material.dart';

/// 2026 성인 커뮤니티 앱 스타일 컬러 시스템
/// iOS Human Interface Guidelines 기반 Muted Palette
class AppColors {
  AppColors._();

  // ========== Light Mode ==========

  // Background
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF9F9F9);
  static const lightSurfaceSecondary = Color(0xFFF2F2F7);

  // Text
  static const lightTextPrimary = Color(0xFF1C1C1E);
  static const lightTextSecondary = Color(0xFF8E8E93);
  static const lightTextTertiary = Color(0xFFAEAEB2);

  // Separator
  static const lightSeparator = Color(0xFFC6C6C8);
  static const lightSeparatorOpaque = Color(0xFFE5E5EA);

  // Accent (절제된 사용)
  static const lightAccent = Color(0xFF007AFF);
  static const lightAccentSubtle = Color(0xFFE8F0FE);

  // Status (톤다운된 버전)
  static const lightTimerRunning = Color(0xFF34A853);
  static const lightTimerPaused = Color(0xFFB5860F);
  static const lightError = Color(0xFFC53929);
  static const lightSuccess = Color(0xFF34A853);

  // ========== Dark Mode ==========

  // Background
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkSurfaceSecondary = Color(0xFF2C2C2E);

  // Text
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E8E93);
  static const darkTextTertiary = Color(0xFF636366);

  // Separator
  static const darkSeparator = Color(0xFF545458);
  static const darkSeparatorOpaque = Color(0xFF38383A);

  // Accent
  static const darkAccent = Color(0xFF0A84FF);
  static const darkAccentSubtle = Color(0xFF1C3A5F);

  // Status (다크모드용)
  static const darkTimerRunning = Color(0xFF4CAF50);
  static const darkTimerPaused = Color(0xFFD4A017);
  static const darkError = Color(0xFFEF5350);
  static const darkSuccess = Color(0xFF4CAF50);
}

/// 테마 확장을 통한 컬러 접근
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color separator;
  final Color separatorOpaque;
  final Color accent;
  final Color accentSubtle;
  final Color timerRunning;
  final Color timerPaused;
  final Color error;
  final Color success;

  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.separator,
    required this.separatorOpaque,
    required this.accent,
    required this.accentSubtle,
    required this.timerRunning,
    required this.timerPaused,
    required this.error,
    required this.success,
  });

  static const light = AppColorsExtension(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceSecondary: AppColors.lightSurfaceSecondary,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    separator: AppColors.lightSeparator,
    separatorOpaque: AppColors.lightSeparatorOpaque,
    accent: AppColors.lightAccent,
    accentSubtle: AppColors.lightAccentSubtle,
    timerRunning: AppColors.lightTimerRunning,
    timerPaused: AppColors.lightTimerPaused,
    error: AppColors.lightError,
    success: AppColors.lightSuccess,
  );

  static const dark = AppColorsExtension(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceSecondary: AppColors.darkSurfaceSecondary,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    separator: AppColors.darkSeparator,
    separatorOpaque: AppColors.darkSeparatorOpaque,
    accent: AppColors.darkAccent,
    accentSubtle: AppColors.darkAccentSubtle,
    timerRunning: AppColors.darkTimerRunning,
    timerPaused: AppColors.darkTimerPaused,
    error: AppColors.darkError,
    success: AppColors.darkSuccess,
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? separator,
    Color? separatorOpaque,
    Color? accent,
    Color? accentSubtle,
    Color? timerRunning,
    Color? timerPaused,
    Color? error,
    Color? success,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      separator: separator ?? this.separator,
      separatorOpaque: separatorOpaque ?? this.separatorOpaque,
      accent: accent ?? this.accent,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      timerRunning: timerRunning ?? this.timerRunning,
      timerPaused: timerPaused ?? this.timerPaused,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      separatorOpaque: Color.lerp(separatorOpaque, other.separatorOpaque, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSubtle: Color.lerp(accentSubtle, other.accentSubtle, t)!,
      timerRunning: Color.lerp(timerRunning, other.timerRunning, t)!,
      timerPaused: Color.lerp(timerPaused, other.timerPaused, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

/// BuildContext 확장으로 편리하게 컬러 접근
extension AppColorsContext on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}
