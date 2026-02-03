import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

/// 커스텀 구분선 컴포넌트
class AppSeparator extends StatelessWidget {
  final double? indent;
  final double? endIndent;
  final double? thickness;
  final Color? color;

  const AppSeparator({
    super.key,
    this.indent,
    this.endIndent,
    this.thickness,
    this.color,
  });

  /// 전체 너비 구분선
  const AppSeparator.full({
    super.key,
    this.thickness,
    this.color,
  })  : indent = 0,
        endIndent = 0;

  /// Inset 구분선 (좌측 여백 있음, iOS 스타일)
  const AppSeparator.inset({
    super.key,
    double leftIndent = 60,
    this.thickness,
    this.color,
  })  : indent = leftIndent,
        endIndent = 0;

  /// 양쪽 여백 있는 구분선
  const AppSeparator.padded({
    super.key,
    double horizontal = 16,
    this.thickness,
    this.color,
  })  : indent = horizontal,
        endIndent = horizontal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: thickness ?? 0.5,
      margin: EdgeInsets.only(
        left: indent ?? 0,
        right: endIndent ?? 0,
      ),
      color: color ?? colors.separatorOpaque,
    );
  }
}

/// 섹션 사이의 공간을 나타내는 구분자
class SectionSpacer extends StatelessWidget {
  final double height;
  final Color? color;

  const SectionSpacer({
    super.key,
    this.height = 24,
    this.color,
  });

  /// 작은 간격
  const SectionSpacer.small({
    super.key,
    this.color,
  }) : height = 12;

  /// 중간 간격
  const SectionSpacer.medium({
    super.key,
    this.color,
  }) : height = 24;

  /// 큰 간격
  const SectionSpacer.large({
    super.key,
    this.color,
  }) : height = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: height,
      color: color ?? colors.background,
    );
  }
}

/// 그룹화된 리스트의 배경 역할을 하는 컨테이너
class GroupedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const GroupedContainer({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );
  }
}
