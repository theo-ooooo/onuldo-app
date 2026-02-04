import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/models.dart';
import '../../../shared/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

@RoutePage()
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
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myUserId = ref.read(authProvider).user?.id;
      ref.read(userProfileProvider.notifier).loadUser(widget.userId);
      ref
          .read(userProfileProvider.notifier)
          .loadFollowers(widget.userId, myUserId: myUserId);
      ref.read(userProfileProvider.notifier).loadFollowing(widget.userId);
      ref.read(userProfileProvider.notifier).loadUserFeed(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // dispose 후에는 ref를 사용할 수 없으므로 clear는 제거
    // 필요시 provider의 자동 정리 기능을 사용하거나
    // 다른 생명주기에서 처리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileProvider);
    final authState = ref.watch(authProvider);
    final myInfoAsync = ref.watch(myInfoProvider);
    final resolvedMyUserId =
        authState.user?.id ?? myInfoAsync.maybeWhen(data: (u) => u.userId, orElse: () => null);
    // 내 userId를 확실히 알기 전에는 팔로우 버튼을 숨김(자기 자신 팔로우 방지)
    final canDetermineMyUserId = resolvedMyUserId != null;
    final isMyProfile =
        canDetermineMyUserId && resolvedMyUserId == widget.userId;
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
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
                    ? Center(
                        child: Text(
                          '사용자를 찾을 수 없습니다',
                          style: typography.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      )
                    : _buildContent(
                        state,
                        isMyProfile: isMyProfile,
                        showFollowButton: canDetermineMyUserId && !isMyProfile,
                      ),
      ),
    );
  }

  Widget _buildContent(
    UserProfileState state, {
    required bool isMyProfile,
    required bool showFollowButton,
  }) {
    final user = state.user!;
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.router.maybePop(),
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
                  user.nickname,
                  style: typography.title3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Profile card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(20),
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
                              color: colors.textPrimary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.nickname,
                  style: typography.title3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.bio!,
                    style: typography.subhead.copyWith(
                      color: colors.textTertiary,
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
                      color: colors.separatorOpaque,
                    ),
                    _StatItem(
                      label: '팔로잉',
                      value: user.followingCount.toString(),
                    ),
                  ],
                ),

                if (showFollowButton) ...[
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
              const SizedBox(width: 8),
              _TabButton(
                label: '팔로잉 ${user.followingCount}',
                isSelected: _tabController.index == 1,
                onTap: () {
                  _tabController.animateTo(1);
                  setState(() {});
                },
              ),
              const SizedBox(width: 8),
              _TabButton(
                label: '피드 ${state.feedItems.length}',
                isSelected: _tabController.index == 2,
                onTap: () {
                  _tabController.animateTo(2);
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
              _UserFeedList(
                items: state.feedItems,
                isLoading: state.isFeedLoading,
                error: state.feedError,
                onRetry: () => ref
                    .read(userProfileProvider.notifier)
                    .loadUserFeed(widget.userId),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserFeedList extends StatelessWidget {
  final List<FeedItemResponse> items;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _UserFeedList({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (isLoading) {
      return const Center(child: LoadingIndicator(size: 48));
    }
    if (error != null) {
      return ErrorView(message: error!, onRetry: onRetry);
    }
    if (items.isEmpty) {
      return Center(
        child: Text(
          '아직 공개된 기록이 없습니다',
          style: typography.body.copyWith(color: colors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.separatorOpaque),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.hobbyName,
                      style: typography.caption1.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.activityDate,
                    style: typography.caption2.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (item.memo != null && item.memo!.trim().isNotEmpty)
                Text(
                  item.memo!,
                  style: typography.body.copyWith(
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                )
              else
                Text(
                  '메모 없음',
                  style: typography.body.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: colors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    DurationFormatter.formatHumanReadable(
                      Duration(seconds: item.durationSeconds),
                    ),
                    style: typography.footnote.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.favorite_border,
                      size: 16, color: colors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    item.totalReactionCount.toString(),
                    style: typography.footnote.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.chat_bubble_outline,
                      size: 16, color: colors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    item.commentCount.toString(),
                    style: typography.footnote.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
            fontWeight: FontWeight.w600,
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

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({
    required this.isFollowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isFollowing ? colors.surface : colors.textPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFollowing ? colors.separatorOpaque : colors.textPrimary,
          ),
        ),
        child: Center(
          child: Text(
            isFollowing ? '팔로잉' : '팔로우',
            style: typography.headline.copyWith(
              color: isFollowing ? colors.textPrimary : colors.background,
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
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.textPrimary : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.textPrimary : colors.separatorOpaque,
          ),
        ),
        child: Text(
          label,
          style: typography.subhead.copyWith(
            color: isSelected ? colors.background : colors.textSecondary,
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
    final colors = context.colors;
    final typography = context.typography;

    if (users.isEmpty) {
      return Center(
        child: Text(
          '목록이 비어있습니다',
          style: typography.subhead.copyWith(
            color: colors.textTertiary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: users.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: colors.separatorOpaque,
        indent: 68,
      ),
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
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
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
                        color: colors.textSecondary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.nickname,
              style: typography.body.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (user.isFollowing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '팔로잉',
                style: typography.caption1.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
