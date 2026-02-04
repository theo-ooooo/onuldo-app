import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

/// 통일된 페이지 헤더 (탭 내부 페이지용)
/// - largeTitle 스타일
/// - 오른쪽에 trailing 위젯 표시 가능
class PageHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsets? padding;

  const PageHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: typography.largeTitle,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 통일된 모달/상세 페이지 헤더 (뒤로가기 버튼 포함)
/// - 뒤로가기 버튼 + title2 스타일
/// - 오른쪽에 trailing 위젯 표시 가능
class ModalPageHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsets? padding;
  final VoidCallback? onBack;

  const ModalPageHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => context.router.maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back,
                color: colors.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: typography.title2,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

