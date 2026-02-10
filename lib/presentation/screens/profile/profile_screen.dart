import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/duration_formatter.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/user_repository.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';

@RoutePage()
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hobbyProvider.notifier).loadHobbies();
      // 내 정보 새로고침
      ref.invalidate(myInfoProvider);
      // 알림 뱃지 갱신
      ref.read(notificationProvider.notifier).loadUnreadCount();
      // 통계 정보 로드
      ref.read(statisticsProvider.notifier).loadStatistics();
    });
  }

  Future<void> _performLogout() async {
    // 모든 provider 상태 초기화
    ref.read(hobbyProvider.notifier).reset();
    ref.read(feedProvider.notifier).reset();
    ref.read(timerProvider.notifier).reset();
    ref.read(statisticsProvider.notifier).reset();
    ref.read(followProvider.notifier).reset();
    ref.read(userSearchProvider.notifier).clearSearch();
    ref.read(userProfileProvider.notifier).clear();

    // 로그아웃 처리
    await ref.read(authProvider.notifier).logout();

    if (!mounted) return;

    // 로그인 페이지로 이동 (전체 스택 교체)
    context.router.replaceAll([LoginRoute()]);
  }

  void _showLogoutDialog() {
    final colors = context.colors;
    final typography = context.typography;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '로그아웃',
          style: typography.title3,
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
          style: typography.body.copyWith(
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            child: Text(
              '로그아웃',
              style: TextStyle(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddHobbyDialog() {
    final nameController = TextEditingController();
    final colors = context.colors;
    final typography = context.typography;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '새 취미 추가',
          style: typography.title3,
        ),
        content: TextField(
          controller: nameController,
          style: typography.body,
          decoration: InputDecoration(
            hintText: '취미 이름을 입력하세요',
            hintStyle: typography.body.copyWith(
              color: colors.textTertiary,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final success = await ref.read(hobbyProvider.notifier).createHobby(
                    CreateHobbyRequest(name: nameController.text.trim()),
                  );

              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              '추가',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditHobbyDialog(HobbyResponse hobby) {
    final nameController = TextEditingController(text: hobby.name);
    final colors = context.colors;
    final typography = context.typography;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '취미 수정',
          style: typography.title3,
        ),
        content: TextField(
          controller: nameController,
          style: typography.body,
          decoration: InputDecoration(
            hintText: '취미 이름',
            hintStyle: typography.body.copyWith(
              color: colors.textTertiary,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteHobbyDialog(hobby);
            },
            child: Text(
              '삭제',
              style: TextStyle(color: colors.error),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final success = await ref.read(hobbyProvider.notifier).updateHobby(
                    hobby.id,
                    UpdateHobbyRequest(name: nameController.text.trim()),
                  );

              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              '저장',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteHobbyDialog(HobbyResponse hobby) {
    final colors = context.colors;
    final typography = context.typography;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '취미 삭제',
          style: typography.title3,
        ),
        content: Text(
          '${hobby.name}을(를) 삭제하시겠습니까?\n관련된 기록은 삭제되지 않습니다.',
          style: typography.body.copyWith(
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(hobbyProvider.notifier).deleteHobby(hobby.id);
            },
            child: Text(
              '삭제',
              style: TextStyle(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final myInfoAsync = ref.watch(myInfoProvider);
    final hobbyState = ref.watch(hobbyProvider);
    final notificationState = ref.watch(notificationProvider);
    final statisticsState = ref.watch(statisticsProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              PageHeader(
                title: '프로필',
                trailing: _NotificationIconButton(
                  unreadCount: notificationState.unreadCount,
                  onTap: () {
                    ref.read(notificationProvider.notifier).loadNotifications();
                    context.router.push(const NotificationRoute());
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Profile section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: myInfoAsync.when(
                  data: (user) => GestureDetector(
                    onTap: () {
                      context.router.push(UserProfileRoute(userId: user.userId));
                    },
                    child: _ProfileCard(
                      user: user,
                      onEdit: () {
                        context.router.push(const EditProfileRoute());
                      },
                    ),
                  ),
                  loading: () => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: LoadingIndicator(size: 24)),
                  ),
                  error: (error, stack) => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '프로필을 불러올 수 없습니다',
                      style: typography.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Statistics section
              if (statisticsState.monthly != null || statisticsState.streak != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _StatisticsCard(
                    monthly: statisticsState.monthly,
                    streak: statisticsState.streak,
                  ),
                ),

              if (statisticsState.monthly != null || statisticsState.streak != null)
                const SizedBox(height: 24),

              // Hobbies section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '내 취미',
                      style: typography.title2,
                    ),
                    _IconButton(
                      icon: Icons.add,
                      onTap: _showAddHobbyDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (hobbyState.isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: LoadingIndicator()),
                )
              else if (hobbyState.hobbies.isEmpty)
                _EmptyHobbiesView(onAddTap: _showAddHobbyDialog)
              else
                AppListSection(
                  children: hobbyState.hobbies.map((hobby) {
                    return AppIconListTile(
                      icon: Icons.circle,
                      iconColor: colors.timerRunning,
                      iconBackgroundColor: colors.timerRunning.withValues(alpha: 0.12),
                      title: hobby.name,
                      onTap: () => _showEditHobbyDialog(hobby),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 32),

              // Settings section
              SectionHeader(
                title: '설정',
                padding: const EdgeInsets.fromLTRB(36, 0, 20, 8),
              ),

              AppListSection(
                children: [
                  _ThemeSettingTile(),
                  AppIconListTile(
                    icon: Icons.lock_outline,
                    iconColor: colors.textPrimary,
                    iconBackgroundColor: colors.surfaceSecondary,
                    title: '비밀번호 변경',
                    onTap: () {
                      context.router.push(const ChangePasswordRoute());
                    },
                  ),
                  AppIconListTile(
                    icon: Icons.logout,
                    iconColor: colors.error,
                    iconBackgroundColor: colors.error.withValues(alpha: 0.12),
                    title: '로그아웃',
                    showChevron: false,
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

class _NotificationIconButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _NotificationIconButton({
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.notifications_none,
                size: 20,
                color: colors.textSecondary,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.error,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colors.background, width: 2),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserResponse user;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.user,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: user.profileImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: user.profileImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Text(
                              user.nickname.isNotEmpty
                                  ? user.nickname[0].toUpperCase()
                                  : 'U',
                              style: typography.title1.copyWith(
                                fontWeight: FontWeight.w300,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              user.nickname.isNotEmpty
                                  ? user.nickname[0].toUpperCase()
                                  : 'U',
                              style: typography.title1.copyWith(
                                fontWeight: FontWeight.w300,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          user.nickname.isNotEmpty
                              ? user.nickname[0].toUpperCase()
                              : 'U',
                          style: typography.title1.copyWith(
                            fontWeight: FontWeight.w300,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      style: typography.title2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (user.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: typography.subhead.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.bio!,
                style: typography.body.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: '팔로워',
                value: user.followerCount.toString(),
              ),
              Container(
                width: 1,
                height: 32,
                color: colors.separatorOpaque,
              ),
              _StatItem(
                label: '팔로잉',
                value: user.followingCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      children: [
        Text(
          value,
          style: typography.title3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: typography.footnote.copyWith(
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final MonthlyStatisticsResponse? monthly;
  final StreakResponse? streak;

  const _StatisticsCard({
    this.monthly,
    this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 달 통계',
            style: typography.title3.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_outlined,
                  iconColor: colors.timerRunning,
                  label: '총 시간',
                  value: monthly != null
                      ? DurationFormatter.formatHumanReadable(
                          Duration(seconds: monthly!.totalDurationSeconds),
                        )
                      : '0분',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: colors.textSecondary,
                  label: '기록 수',
                  value: monthly?.recordCount.toString() ?? '0',
                ),
              ),
            ],
          ),
          if (streak != null && streak!.currentStreak > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: colors.timerRunning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${streak!.currentStreak}일 연속',
                          style: typography.title3.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '최장 ${streak!.longestStreak}일',
                          style: typography.footnote.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: typography.title3.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: typography.footnote.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSettingTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final themeState = ref.watch(themeProvider);

    String themeModeLabel;
    switch (themeState.themeMode) {
      case AppThemeMode.system:
        themeModeLabel = '시스템';
        break;
      case AppThemeMode.light:
        themeModeLabel = '라이트';
        break;
      case AppThemeMode.dark:
        themeModeLabel = '다크';
        break;
    }

    return AppIconListTile(
      icon: Icons.brightness_6_outlined,
      iconColor: colors.textSecondary,
      title: '테마',
      trailing: Text(
        themeModeLabel,
        style: typography.subhead.copyWith(
          color: colors.textSecondary,
        ),
      ),
      onTap: () => _showThemeSelector(context, ref),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final currentMode = ref.read(themeProvider).themeMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.separator,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  '테마 선택',
                  style: typography.title3,
                ),
                const SizedBox(height: 16),

                _ThemeOption(
                  icon: Icons.phone_android,
                  label: '시스템 설정',
                  subtitle: '기기 설정에 따라 자동 전환',
                  isSelected: currentMode == AppThemeMode.system,
                  onTap: () {
                    ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
                _ThemeOption(
                  icon: Icons.light_mode_outlined,
                  label: '라이트 모드',
                  isSelected: currentMode == AppThemeMode.light,
                  onTap: () {
                    ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                _ThemeOption(
                  icon: Icons.dark_mode_outlined,
                  label: '다크 모드',
                  isSelected: currentMode == AppThemeMode.dark,
                  onTap: () {
                    ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.textTertiary : colors.separatorOpaque,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: typography.body.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: typography.footnote.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: colors.textPrimary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHobbiesView extends StatelessWidget {
  final VoidCallback onAddTap;

  const _EmptyHobbiesView({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return SizedBox(
      width: double.infinity,
      child: GroupedContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.palette_outlined,
                size: 24,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 등록된 취미가 없습니다',
              style: typography.body.copyWith(
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onAddTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '취미 추가하기',
                  style: typography.subhead.copyWith(
                    color: colors.background,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
