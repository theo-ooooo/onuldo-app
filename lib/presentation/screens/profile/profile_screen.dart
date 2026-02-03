import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../data/models/models.dart';
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  '프로필',
                  style: typography.largeTitle,
                ),
              ),

              const SizedBox(height: 32),

              // Profile section
              AppListSection(
                children: [
                  myInfoAsync.when(
                    data: (user) => _ProfileTile(
                      nickname: user.nickname,
                      email: user.email,
                      profileImageUrl: user.profileImageUrl,
                      bio: user.bio,
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: LoadingIndicator(size: 24)),
                    ),
                    error: (error, stack) => _ProfileTile(
                      nickname: '사용자',
                      email: '',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

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

class _ProfileTile extends StatelessWidget {
  final String nickname;
  final String email;
  final String? profileImageUrl;
  final String? bio;

  const _ProfileTile({
    required this.nickname,
    required this.email,
    this.profileImageUrl,
    this.bio,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(30),
              image: profileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profileImageUrl == null
                ? Center(
                    child: Text(
                      nickname.isNotEmpty ? nickname[0].toUpperCase() : 'U',
                      style: typography.title1.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: typography.title3,
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: typography.subhead.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                if (bio != null && bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    bio!,
                    style: typography.footnote.copyWith(
                      color: colors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
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
