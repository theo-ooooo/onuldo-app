import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  int _getCurrentIndex(BuildContext context) {
    final location = context.router.current.name;
    if (location == 'TimerRoute') return 0;
    if (location == 'FeedRoute') return 1;
    if (location == 'StatisticsRoute') return 2;
    if (location == 'UserSearchRoute') return 3;
    if (location == 'ProfileRoute') return 4;
    return 0;
  }

  void _onTap(BuildContext context, WidgetRef ref, int index, int currentIndex) {
    switch (index) {
      case 0:
        // 타이머 탭으로 이동할 때 현재 타이머 상태 새로고침
        ref.read(timerProvider.notifier).loadCurrentTimer();
        context.router.navigate(const TimerRoute());
        break;
      case 1:
        // 피드 탭으로 이동할 때 항상 새로고침
        ref.read(feedProvider.notifier).refresh();
        context.router.navigate(const FeedRoute());
        break;
      case 2:
        // 통계 탭으로 이동할 때 통계 새로고침
        ref.read(statisticsProvider.notifier).loadStatistics();
        context.router.navigate(const StatisticsRoute());
        break;
      case 3:
        context.router.navigate(const UserSearchRoute());
        break;
      case 4:
        // 프로필 탭으로 이동할 때 취미 목록 새로고침
        ref.read(hobbyProvider.notifier).loadHobbies();
        context.router.navigate(const ProfileRoute());
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: const AutoRouter(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(
            top: BorderSide(
              color: colors.separatorOpaque,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.timer_outlined,
                  activeIcon: Icons.timer,
                  label: '타이머',
                  isSelected: currentIndex == 0,
                  onTap: () => _onTap(context, ref, 0, currentIndex),
                ),
                _NavItem(
                  icon: Icons.article_outlined,
                  activeIcon: Icons.article,
                  label: '피드',
                  isSelected: currentIndex == 1,
                  onTap: () => _onTap(context, ref, 1, currentIndex),
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: '통계',
                  isSelected: currentIndex == 2,
                  onTap: () => _onTap(context, ref, 2, currentIndex),
                ),
                _NavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: '검색',
                  isSelected: currentIndex == 3,
                  onTap: () => _onTap(context, ref, 3, currentIndex),
                ),
                _NavItem(
                  icon: Icons.person_outlined,
                  activeIcon: Icons.person,
                  label: '프로필',
                  isSelected: currentIndex == 4,
                  onTap: () => _onTap(context, ref, 4, currentIndex),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected ? colors.textPrimary : colors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: typography.caption2.copyWith(
                color: isSelected ? colors.textPrimary : colors.textTertiary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
