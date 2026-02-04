import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsRouter.builder(
      routes: const [
        TimerRoute(),
        FeedRoute(),
        StatisticsRoute(),
        UserSearchRoute(),
        ProfileRoute(),
      ],
      builder: (context, children, tabsRouter) {
        final colors = context.colors;
        final currentIndex = tabsRouter.activeIndex;

        void onTap(int index) {
          if (tabsRouter.activeIndex == index) return;

          switch (index) {
            case 0:
              ref.read(timerProvider.notifier).loadCurrentTimer();
              break;
            case 1:
              ref.read(feedProvider.notifier).refresh();
              break;
            case 2:
              ref.read(statisticsProvider.notifier).loadStatistics();
              break;
            case 4:
              ref.read(hobbyProvider.notifier).loadHobbies();
              break;
          }

          tabsRouter.setActiveIndex(index);
        }

        return Scaffold(
          body: children[currentIndex],
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
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.article_outlined,
                      activeIcon: Icons.article,
                      label: '피드',
                      isSelected: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      label: '통계',
                      isSelected: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.search_outlined,
                      activeIcon: Icons.search,
                      label: '검색',
                      isSelected: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                    _NavItem(
                      icon: Icons.person_outlined,
                      activeIcon: Icons.person,
                      label: '프로필',
                      isSelected: currentIndex == 4,
                      onTap: () => onTap(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
