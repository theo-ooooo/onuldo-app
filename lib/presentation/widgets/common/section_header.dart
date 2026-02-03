import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

/// iOS 스타일 섹션 헤더
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onActionTap;
  final EdgeInsets? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: typography.footnote.copyWith(
              color: colors.textSecondary,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                action!,
                style: typography.footnote.copyWith(
                  color: colors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 큰 타이틀을 가진 섹션 헤더
class LargeSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onActionTap;
  final Widget? trailing;
  final EdgeInsets? padding;

  const LargeSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: typography.title2,
          ),
          if (trailing != null)
            trailing!
          else if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action!,
                    style: typography.subhead.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 페이지 타이틀 (Large Title 스타일)
class PageTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsets? padding;

  const PageTitle({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: typography.largeTitle,
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
