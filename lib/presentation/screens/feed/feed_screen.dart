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

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).loadFeed();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final feedType = _tabController.index == 0 ? FeedType.all : FeedType.following;
    ref.read(feedProvider.notifier).changeFeedType(feedType);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('피드'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '팔로잉'),
          ],
        ),
        actions: [
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) {
              ref.read(feedProvider.notifier).changeSortType(sort);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortType.latest,
                child: Row(
                  children: [
                    if (feedState.sortType == SortType.latest)
                      const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('최신순'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortType.popular,
                child: Row(
                  children: [
                    if (feedState.sortType == SortType.popular)
                      const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('인기순'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(feedState),
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
      return EmptyView(
        message: state.feedType == FeedType.following
            ? '팔로우한 사람의 기록이 없습니다'
            : '아직 기록이 없습니다',
        icon: Icons.feed_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingIndicator()),
            );
          }

          final item = state.items[index];
          return _FeedCard(
            item: item,
            onReaction: (emoji) {
              if (item.myReaction == emoji) {
                ref.read(feedProvider.notifier).removeReaction(item.id);
              } else {
                ref.read(feedProvider.notifier).addReaction(item.id, emoji);
              }
            },
          );
        },
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: item.userProfileImageUrl != null
                      ? NetworkImage(item.userProfileImageUrl!)
                      : null,
                  child: item.userProfileImageUrl == null
                      ? Text(
                          item.userNickname[0].toUpperCase(),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
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
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(
                        _formatTime(item.recordedAt),
                        style: AppTextStyles.bodySmall,
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
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.hobbyName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Duration
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  DurationFormatter.formatHumanReadable(
                    Duration(seconds: item.durationSeconds),
                  ),
                  style: AppTextStyles.h4,
                ),
              ],
            ),

            if (item.memo != null && item.memo!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                item.memo!,
                style: AppTextStyles.bodyMedium,
              ),
            ],

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

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
                    '${item.reactionCount}개의 반응',
                    style: AppTextStyles.bodySmall,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Text(
          emoji.emoji,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
