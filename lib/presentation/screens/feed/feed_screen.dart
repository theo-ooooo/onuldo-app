import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  const AppLogoIcon(size: 44),
                  const SizedBox(width: 12),
                  Text(
                    '피드',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                    ),
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

            const SizedBox(height: 24),

            // Feed type selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _FeedTypeChip(
                    label: '전체',
                    isSelected: _selectedFeedType == FeedType.all,
                    onTap: () => _changeFeedType(FeedType.all),
                  ),
                  const SizedBox(width: 12),
                  _FeedTypeChip(
                    label: '팔로잉',
                    isSelected: _selectedFeedType == FeedType.following,
                    onTap: () => _changeFeedType(FeedType.following),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
      color: AppColors.textPrimary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: LoadingIndicator()),
            );
          }

          final item = state.items[index];
          return _FeedCard(
            item: item,
            onReaction: (emoji) {
              if (item.myReaction == emoji) {
                ref.read(feedProvider.notifier).removeReaction(item.recordId);
              } else {
                ref.read(feedProvider.notifier).addReaction(item.recordId, emoji);
              }
            },
          );
        },
      ),
    );
  }
}

class _FeedTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.background : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
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
    return PopupMenuButton<SortType>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.surface,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              sortType == SortType.latest ? '최신순' : '인기순',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
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
                    ? AppColors.textPrimary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(
                '최신순',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
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
                    ? AppColors.textPrimary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(
                '인기순',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.feed_outlined,
              size: 36,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            feedType == FeedType.following
                ? '팔로우한 사람의 기록이 없습니다'
                : '아직 기록이 없습니다',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final FeedItemResponse item;
  final ValueChanged<EmojiType> onReaction;

  const _FeedCard({
    required this.item,
    required this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
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
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
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
                    Text(
                      item.userNickname,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.createdAt != null
                          ? _formatTime(item.createdAt!)
                          : item.activityDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.hobbyName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Duration
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.timerRunning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: AppColors.timerRunning,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                DurationFormatter.formatHumanReadable(
                  Duration(seconds: item.durationSeconds),
                ),
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (item.memo != null && item.memo!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.memo!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            color: AppColors.border,
          ),

          const SizedBox(height: 16),

          // Reactions
          Row(
            children: [
              ...EmojiType.values.map((emoji) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _ReactionButton(
                      emoji: emoji,
                      isSelected: item.myReaction == emoji,
                      onTap: () => onReaction(emoji),
                    ),
                  )),
              const Spacer(),
              if (item.reactionCount > 0)
                Text(
                  '${item.reactionCount}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ],
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
  final bool isSelected;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.textPrimary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.textPrimary.withValues(alpha: 0.3))
              : null,
        ),
        child: Text(
          emoji.emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
