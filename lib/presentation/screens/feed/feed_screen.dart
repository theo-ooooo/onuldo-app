import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../router/app_router.dart';

@RoutePage()
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();
  FeedType _selectedFeedType = FeedType.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).loadFeed();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  void _changeFeedType(FeedType type) {
    if (_selectedFeedType == type) return;
    setState(() {
      _selectedFeedType = type;
    });
    ref.read(feedProvider.notifier).changeFeedType(type);
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    '피드',
                    style: typography.largeTitle,
                  ),
                  const Spacer(),
                  _SortButton(
                    sortType: feedState.sortType,
                    onChanged: (sort) {
                      ref.read(feedProvider.notifier).changeSortType(sort);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Feed type selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  AppChip(
                    label: '전체',
                    isSelected: _selectedFeedType == FeedType.all,
                    onTap: () => _changeFeedType(FeedType.all),
                  ),
                  const SizedBox(width: 8),
                  AppChip(
                    label: '팔로잉',
                    isSelected: _selectedFeedType == FeedType.following,
                    onTap: () => _changeFeedType(FeedType.following),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Feed content
            Expanded(
              child: _buildBody(feedState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(FeedState state) {
    final colors = context.colors;

    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: LoadingIndicator(size: 48));
    }

    if (state.error != null && state.items.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(feedProvider.notifier).refresh(),
      );
    }

    if (state.items.isEmpty) {
      return _EmptyFeedView(
        feedType: state.feedType,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      color: colors.textPrimary,
      backgroundColor: colors.surface,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const AppSeparator.full(),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: LoadingIndicator()),
            );
          }

          final item = state.items[index];
          return _FeedItem(
            item: item,
            onReaction: (emoji) {
              ref.read(feedProvider.notifier).toggleReaction(item.recordId, emoji);
            },
            onUserTap: () {
              context.router.push(UserProfileRoute(userId: item.userId));
            },
            onCommentTap: () {
              showCommentBottomSheet(context, item.recordId);
            },
          );
        },
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final SortType sortType;
  final ValueChanged<SortType> onChanged;

  const _SortButton({
    required this.sortType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return PopupMenuButton<SortType>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colors.surface,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 18,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              sortType == SortType.latest ? '최신순' : '인기순',
              style: typography.footnote.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SortType.latest,
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 16,
                color: sortType == SortType.latest
                    ? colors.textPrimary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(
                '최신순',
                style: typography.body,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: SortType.popular,
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 16,
                color: sortType == SortType.popular
                    ? colors.textPrimary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(
                '인기순',
                style: typography.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyFeedView extends StatelessWidget {
  final FeedType feedType;

  const _EmptyFeedView({required this.feedType});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.article_outlined,
              size: 28,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            feedType == FeedType.following
                ? '팔로우한 사람의 기록이 없습니다'
                : '아직 기록이 없습니다',
            style: typography.body.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedItem extends StatelessWidget {
  final FeedItemResponse item;
  final ValueChanged<EmojiType> onReaction;
  final VoidCallback? onUserTap;
  final VoidCallback? onCommentTap;

  const _FeedItem({
    required this.item,
    required this.onReaction,
    this.onUserTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.surfaceSecondary,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            GestureDetector(
              onTap: onUserTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      shape: BoxShape.circle,
                      image: item.userProfileImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(item.userProfileImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.userProfileImageUrl == null
                        ? Center(
                            child: Text(
                              item.userNickname[0].toUpperCase(),
                              style: typography.headline.copyWith(
                                color: colors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.userNickname,
                              style: typography.headline.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.timerRunning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.hobbyName,
                                style: typography.caption1.copyWith(
                                  color: colors.timerRunning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.createdAt != null
                              ? _formatTime(item.createdAt!)
                              : item.activityDate,
                          style: typography.footnote.copyWith(
                            color: colors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Duration
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: colors.timerRunning,
                ),
                const SizedBox(width: 6),
                Text(
                  DurationFormatter.formatHumanReadable(
                    Duration(seconds: item.durationSeconds),
                  ),
                  style: typography.title3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),

            // Memo
            if (item.memo != null && item.memo!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                item.memo!,
                style: typography.body.copyWith(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Reactions and Comments
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...EmojiType.values.map((emoji) => _ReactionButton(
                            emoji: emoji,
                            count: item.getReactionCount(emoji),
                            isSelected: item.hasMyReaction(emoji),
                            onTap: () => onReaction(emoji),
                          )),
                      // Comment button
                      GestureDetector(
                        onTap: onCommentTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 16,
                                color: colors.textTertiary,
                              ),
                              if (item.commentCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '${item.commentCount}',
                                  style: typography.caption1.copyWith(
                                    color: colors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.totalReactionCount > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.totalReactionCount}',
                        style: typography.footnote.copyWith(
                          color: colors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return '방금 전';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}

class _ReactionButton extends StatelessWidget {
  final EmojiType emoji;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
    required this.count,
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.timerRunning.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            if (count > 0) ...[
              const SizedBox(width: 3),
              Text(
                '$count',
                style: typography.caption1.copyWith(
                  color: isSelected
                      ? colors.timerRunning
                      : colors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
