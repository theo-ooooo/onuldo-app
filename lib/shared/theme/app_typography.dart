
import 'package:flutter/material.dart';

/// 2026 성인 커뮤니티 앱 스타일 타이포그래피 시스템
/// iOS Human Interface Guidelines 기반 시스템 폰트 활용
class AppTypography {
  AppTypography._();

  /// Large Title - 화면 제목
  static const largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.2,
  );

  /// Title 1 - 섹션 제목
  static const title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
    height: 1.21,
  );

  /// Title 2 - 카드/리스트 그룹 제목
  static const title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
    height: 1.27,
  );

  /// Title 3 - 소제목
  static const title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    height: 1.25,
  );

  /// Headline - 강조 텍스트
  static const headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Body - 본문
  static const body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.47,
  );

  /// Callout - 부가 정보
  static const callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.31,
  );

  /// Subhead - 메타 정보
  static const subhead = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.33,
  );

  /// Footnote - 각주, 타임스탬프
  static const footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38,
  );

  /// Caption 1 - 레이블
  static const caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );

  /// Caption 2 - 작은 레이블
  static const caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    height: 1.18,
  );

  /// Timer Display - 타이머 숫자 표시
  static const timerDisplay = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w200,
    letterSpacing: 4,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Timer Display Large - 큰 타이머 숫자 표시
  static const timerDisplayLarge = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w100,
    letterSpacing: 6,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Statistics Number - 통계 숫자
  static const statisticsNumber = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w300,
    letterSpacing: 1,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

/// 테마 확장을 통한 타이포그래피 접근
class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  final TextStyle largeTitle;
  final TextStyle title1;
  final TextStyle title2;
  final TextStyle title3;
  final TextStyle headline;
  final TextStyle body;
  final TextStyle callout;
  final TextStyle subhead;
  final TextStyle footnote;
  final TextStyle caption1;
  final TextStyle caption2;
  final TextStyle timerDisplay;
  final TextStyle timerDisplayLarge;
  final TextStyle statisticsNumber;

  const AppTypographyExtension({
    required this.largeTitle,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.headline,
    required this.body,
    required this.callout,
    required this.subhead,
    required this.footnote,
    required this.caption1,
    required this.caption2,
    required this.timerDisplay,
    required this.timerDisplayLarge,
    required this.statisticsNumber,
  });

  static AppTypographyExtension fromColor(Color textColor) {
    return AppTypographyExtension(
      largeTitle: AppTypography.largeTitle.copyWith(color: textColor),
      title1: AppTypography.title1.copyWith(color: textColor),
      title2: AppTypography.title2.copyWith(color: textColor),
      title3: AppTypography.title3.copyWith(color: textColor),
      headline: AppTypography.headline.copyWith(color: textColor),
      body: AppTypography.body.copyWith(color: textColor),
      callout: AppTypography.callout.copyWith(color: textColor),
      subhead: AppTypography.subhead.copyWith(color: textColor),
      footnote: AppTypography.footnote.copyWith(color: textColor),
      caption1: AppTypography.caption1.copyWith(color: textColor),
      caption2: AppTypography.caption2.copyWith(color: textColor),
      timerDisplay: AppTypography.timerDisplay.copyWith(color: textColor),
      timerDisplayLarge: AppTypography.timerDisplayLarge.copyWith(color: textColor),
      statisticsNumber: AppTypography.statisticsNumber.copyWith(color: textColor),
    );
  }

  @override
  ThemeExtension<AppTypographyExtension> copyWith({
    TextStyle? largeTitle,
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? headline,
    TextStyle? body,
    TextStyle? callout,
    TextStyle? subhead,
    TextStyle? footnote,
    TextStyle? caption1,
    TextStyle? caption2,
    TextStyle? timerDisplay,
    TextStyle? timerDisplayLarge,
    TextStyle? statisticsNumber,
  }) {
    return AppTypographyExtension(
      largeTitle: largeTitle ?? this.largeTitle,
      title1: title1 ?? this.title1,
      title2: title2 ?? this.title2,
      title3: title3 ?? this.title3,
      headline: headline ?? this.headline,
      body: body ?? this.body,
      callout: callout ?? this.callout,
      subhead: subhead ?? this.subhead,
      footnote: footnote ?? this.footnote,
      caption1: caption1 ?? this.caption1,
      caption2: caption2 ?? this.caption2,
      timerDisplay: timerDisplay ?? this.timerDisplay,
      timerDisplayLarge: timerDisplayLarge ?? this.timerDisplayLarge,
      statisticsNumber: statisticsNumber ?? this.statisticsNumber,
    );
  }

  @override
  ThemeExtension<AppTypographyExtension> lerp(
    covariant ThemeExtension<AppTypographyExtension>? other,
    double t,
  ) {
    if (other is! AppTypographyExtension) {
      return this;
    }
    return AppTypographyExtension(
      largeTitle: TextStyle.lerp(largeTitle, other.largeTitle, t)!,
      title1: TextStyle.lerp(title1, other.title1, t)!,
      title2: TextStyle.lerp(title2, other.title2, t)!,
      title3: TextStyle.lerp(title3, other.title3, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      callout: TextStyle.lerp(callout, other.callout, t)!,
      subhead: TextStyle.lerp(subhead, other.subhead, t)!,
      footnote: TextStyle.lerp(footnote, other.footnote, t)!,
      caption1: TextStyle.lerp(caption1, other.caption1, t)!,
      caption2: TextStyle.lerp(caption2, other.caption2, t)!,
      timerDisplay: TextStyle.lerp(timerDisplay, other.timerDisplay, t)!,
      timerDisplayLarge: TextStyle.lerp(timerDisplayLarge, other.timerDisplayLarge, t)!,
      statisticsNumber: TextStyle.lerp(statisticsNumber, other.statisticsNumber, t)!,
    );
  }
}

/// BuildContext 확장으로 편리하게 타이포그래피 접근
extension AppTypographyContext on BuildContext {
  AppTypographyExtension get typography =>
      Theme.of(this).extension<AppTypographyExtension>() ??
      AppTypographyExtension.fromColor(Colors.black);
}
