import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final int userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).loadUser(widget.userId);
      ref.read(userProfileProvider.notifier).loadFollowers(widget.userId);
      ref.read(userProfileProvider.notifier).loadFollowing(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    ref.read(userProfileProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileProvider);
    final authState = ref.watch(authProvider);
    final isMyProfile = authState.user?.id == widget.userId;

    return Scaffold(
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: LoadingIndicator(size: 48))
            : state.error != null
                ? ErrorView(
                    message: state.error!,
                    onRetry: () => ref
                        .read(userProfileProvider.notifier)
                        .loadUser(widget.userId),
                  )
                : state.user == null
                    ? const Center(child: Text('사용자를 찾을 수 없습니다'))
                    : _buildContent(state, isMyProfile),
      ),
    );
  }

  Widget _buildContent(UserProfileState state, bool isMyProfile) {
    final user = state.user!;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user.nickname,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Profile card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                    image: user.profileImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(user.profileImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user.profileImageUrl == null
                      ? Center(
                          child: Text(
                            user.nickname[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.nickname,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.bio!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatItem(
                      label: '팔로워',
                      value: user.followerCount.toString(),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      color: AppColors.border,
                    ),
                    _StatItem(
                      label: '팔로잉',
                      value: user.followingCount.toString(),
                    ),
                  ],
                ),

                if (!isMyProfile) ...[
                  const SizedBox(height: 20),
                  // Follow button
                  _FollowButton(
                    isFollowing: state.isFollowing,
                    onTap: () {
                      if (state.isFollowing) {
                        ref
                            .read(userProfileProvider.notifier)
                            .unfollow(widget.userId);
                      } else {
                        ref
                            .read(userProfileProvider.notifier)
                            .follow(widget.userId);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _TabButton(
                label: '팔로워 ${user.followerCount}',
                isSelected: _tabController.index == 0,
                onTap: () {
                  _tabController.animateTo(0);
                  setState(() {});
                },
              ),
              const SizedBox(width: 12),
              _TabButton(
                label: '팔로잉 ${user.followingCount}',
                isSelected: _tabController.index == 1,
                onTap: () {
                  _tabController.animateTo(1);
                  setState(() {});
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _FollowList(users: state.followers),
              _FollowList(users: state.following),
            ],
          ),
        ),
      ],
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
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({
    required this.isFollowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isFollowing ? AppColors.surface : const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFollowing ? AppColors.border : const Color(0xFF18181B),
          ),
        ),
        child: Center(
          child: Text(
            isFollowing ? '팔로잉' : '팔로우',
            style: AppTextStyles.button.copyWith(
              color: isFollowing ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF18181B) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _FollowList extends StatelessWidget {
  final List<dynamic> users;

  const _FollowList({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          '목록이 비어있습니다',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _FollowUserTile(user: user);
      },
    );
  }
}

class _FollowUserTile extends StatelessWidget {
  final dynamic user;

  const _FollowUserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              image: user.profileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user.profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.profileImageUrl == null
                ? Center(
                    child: Text(
                      user.nickname[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.nickname,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (user.isFollowing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '팔로잉',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
