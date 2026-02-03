import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';
import 'widgets.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final int recordId;

  const CommentBottomSheet({
    super.key,
    required this.recordId,
  });

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
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
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startReply(int commentId, String nickname) {
    setState(() {
      _replyingToId = commentId;
      _replyingToNickname = nickname;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToNickname = null;
    });
  }

  Future<void> _submitComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final success = await ref.read(commentProvider.notifier).createComment(
          content,
          parentCommentId: _replyingToId,
        );

    if (success) {
      _controller.clear();
      _cancelReply();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.separator,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '댓글',
                  style: typography.title3,
                ),
                const SizedBox(width: 8),
                Text(
                  '${state.comments.length}',
                  style: typography.headline.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const AppSeparator.full(),

          // Comments list
          Expanded(
            child: _buildCommentsList(state),
          ),

          // Reply indicator
          if (_replyingToNickname != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // Input field
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
                      controller: _controller,
                      focusNode: _focusNode,
                      style: typography.body,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요',
                        hintStyle: typography.body.copyWith(
                          color: colors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: state.isSubmitting ? null : _submitComment,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.textPrimary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: state.isSubmitting
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
    );
  }

  Widget _buildCommentsList(CommentState state) {
    final colors = context.colors;
    final typography = context.typography;

    if (state.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.error!,
              style: typography.body.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => ref.read(commentProvider.notifier).loadComments(widget.recordId),
              child: Text(
                '다시 시도',
                style: typography.body.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      );
    }

    if (state.comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              '아직 댓글이 없습니다',
              style: typography.body.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: 4),
            Text(
              '첫 번째 댓글을 남겨보세요',
              style: typography.footnote.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.comments.length,
      itemBuilder: (context, index) {
        final comment = state.comments[index];
        return _CommentItem(
          comment: comment,
          onReply: () => _startReply(comment.id, comment.userNickname),
          onDelete: () => ref.read(commentProvider.notifier).deleteComment(comment.id),
        );
      },
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentResponse comment;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final bool isReply;

  const _CommentItem({
    required this.comment,
    required this.onReply,
    required this.onDelete,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 56 : 16,
        right: 16,
        top: 12,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: isReply ? 28 : 36,
                height: isReply ? 28 : 36,
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(isReply ? 14 : 18),
                  image: comment.userProfileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(comment.userProfileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: comment.userProfileImageUrl == null
                    ? Center(
                        child: Text(
                          comment.userNickname[0].toUpperCase(),
                          style: (isReply ? typography.caption1 : typography.subhead).copyWith(
                            color: colors.textSecondary,
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
                          comment.userNickname,
                          style: typography.subhead.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(comment.createdAt),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (!isReply)
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
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Replies
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...comment.replies.map((reply) => _CommentItem(
                  comment: reply,
                  onReply: () {},
                  onDelete: () {},
                  isReply: true,
                )),
          ],
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

/// 댓글 바텀시트를 표시하는 함수
void showCommentBottomSheet(BuildContext context, int recordId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CommentBottomSheet(recordId: recordId),
  );
}
