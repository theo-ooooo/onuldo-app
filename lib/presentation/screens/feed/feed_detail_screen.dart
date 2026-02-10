import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../router/app_router.dart';

@RoutePage()
class FeedDetailScreen extends ConsumerStatefulWidget {
  final int recordId;

  const FeedDetailScreen({
    super.key,
    required this.recordId,
  });

  @override
  ConsumerState<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends ConsumerState<FeedDetailScreen> {
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  int? _replyingToId;
  String? _replyingToNickname;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentProvider.notifier).loadComments(widget.recordId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _startReply(int commentId, String nickname) {
    setState(() {
      _replyingToId = commentId;
      _replyingToNickname = nickname;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToNickname = null;
    });
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final success = await ref.read(commentProvider.notifier).createComment(
          content,
          parentCommentId: _replyingToId,
        );

    if (success) {
      _commentController.clear();
      _cancelReply();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final commentState = ref.watch(commentProvider);
    final colors = context.colors;
    final typography = context.typography;

    final item = feedState.items.cast<FeedItemResponse?>().firstWhere(
          (i) => i?.recordId == widget.recordId,
          orElse: () => null,
        );

    if (item == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              ModalPageHeader(title: '기록'),
              const Expanded(
                child: Center(child: Text('기록을 찾을 수 없습니다')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ModalPageHeader(title: '기록 상세'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // User info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => context.router.push(
                          UserProfileRoute(userId: item.userId),
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colors.surfaceSecondary,
                                shape: BoxShape.circle,
                              ),
                              child: item.userProfileImageUrl != null
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: item.userProfileImageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(
                                          child: Text(
                                            item.userNickname[0].toUpperCase(),
                                            style: typography.headline.copyWith(
                                              color: colors.textSecondary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Center(
                                          child: Text(
                                            item.userNickname[0].toUpperCase(),
                                            style: typography.headline.copyWith(
                                              color: colors.textSecondary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        item.userNickname[0].toUpperCase(),
                                        style: typography.headline.copyWith(
                                          color: colors.textSecondary,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.userNickname,
                                    style: typography.headline.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.createdAt != null
                                        ? _formatTime(item.createdAt!)
                                        : item.activityDate,
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
                    ),

                    const SizedBox(height: 20),

                    // Activity summary card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.timerRunning
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.hobbyName,
                                style: typography.footnote.copyWith(
                                  color: colors.timerRunning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 20,
                                  color: colors.timerRunning,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DurationFormatter.formatHumanReadable(
                                    Duration(seconds: item.durationSeconds),
                                  ),
                                  style: typography.title2.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Memo
                    if (item.memo != null && item.memo!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          item.memo!,
                          style: typography.body.copyWith(
                            color: colors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    // Images
                    if (item.images.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _ImageSection(
                        images: item.images,
                        onImageTap: (index) {
                          context.router.push(
                            PhotoViewerRoute(
                              imageUrls: item.images
                                  .map((e) => e.imageUrl)
                                  .toList(),
                              initialIndex: index,
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 20),
                    const AppSeparator.full(),
                    const SizedBox(height: 12),

                    // Reactions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: EmojiType.values
                            .map(
                              (emoji) => _ReactionChip(
                                emoji: emoji,
                                count: item.getReactionCount(emoji),
                                isSelected: item.hasMyReaction(emoji),
                                onTap: () => ref
                                    .read(feedProvider.notifier)
                                    .toggleReaction(item.recordId, emoji),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const AppSeparator.full(),

                    // Comments section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Text(
                            '댓글',
                            style: typography.headline.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${commentState.comments.length}',
                            style: typography.headline.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Comments list
                    if (commentState.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: LoadingIndicator()),
                      )
                    else if (commentState.comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            '아직 댓글이 없습니다',
                            style: typography.body.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...commentState.comments.map(
                        (comment) => _CommentItem(
                          comment: comment,
                          onReply: () =>
                              _startReply(comment.id, comment.userNickname),
                        ),
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Reply indicator
            if (_replyingToNickname != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: colors.surfaceSecondary,
                child: Row(
                  children: [
                    Text(
                      '@$_replyingToNickname 에게 답글 작성 중',
                      style: typography.footnote.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

            // Comment input
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(
                    color: colors.separatorOpaque,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        style: typography.body,
                        decoration: InputDecoration(
                          hintText: '댓글을 입력하세요',
                          hintStyle: typography.body.copyWith(
                            color: colors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        maxLines: 3,
                        minLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap:
                        commentState.isSubmitting ? null : _submitComment,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.textPrimary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: commentState.isSubmitting
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.background,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              size: 18,
                              color: colors.background,
                            ),
                    ),
                  ),
                ],
              ),
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

class _CommentItem extends StatelessWidget {
  final CommentResponse comment;
  final VoidCallback? onReply;
  final bool isReply;

  const _CommentItem({
    required this.comment,
    this.onReply,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 56 : 20,
        right: 20,
        top: 8,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isReply ? 28 : 36,
                height: isReply ? 28 : 36,
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  shape: BoxShape.circle,
                ),
                child: comment.userProfileImageUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: comment.userProfileImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Text(
                              comment.userNickname[0].toUpperCase(),
                              style: (isReply
                                      ? typography.caption1
                                      : typography.subhead)
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              comment.userNickname[0].toUpperCase(),
                              style: (isReply
                                      ? typography.caption1
                                      : typography.subhead)
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          comment.userNickname[0].toUpperCase(),
                          style: (isReply
                                  ? typography.caption1
                                  : typography.subhead)
                              .copyWith(color: colors.textSecondary),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userNickname,
                          style: typography.subhead.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatCommentTime(comment.createdAt),
                          style: typography.caption1.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: typography.body,
                    ),
                    if (!isReply) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: onReply,
                        child: Text(
                          '답글',
                          style: typography.caption1.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Replies
          if (comment.replies.isNotEmpty)
            ...comment.replies.map(
              (reply) => _CommentItem(
                comment: reply,
                isReply: true,
              ),
            ),
        ],
      ),
    );
  }

  String _formatCommentTime(DateTime dateTime) {
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

class _ImageSection extends StatelessWidget {
  final List<FeedImageResponse> images;
  final ValueChanged<int> onImageTap;

  const _ImageSection({
    required this.images,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    if (images.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () => onImageTap(0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: images.first.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colors.surfaceSecondary,
                  child: const Center(
                    child: LoadingIndicator(size: 24),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colors.surfaceSecondary,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onImageTap(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: images[index].imageUrl,
                width: 240,
                height: 240,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 240,
                  height: 240,
                  color: colors.surfaceSecondary,
                  child: const Center(
                    child: LoadingIndicator(size: 24),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 240,
                  height: 240,
                  color: colors.surfaceSecondary,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final EmojiType emoji;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReactionChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.timerRunning.withValues(alpha: 0.12)
              : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: colors.timerRunning.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji.emoji,
              style: const TextStyle(fontSize: 18),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: typography.subhead.copyWith(
                  color: isSelected ? colors.timerRunning : colors.textTertiary,
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
