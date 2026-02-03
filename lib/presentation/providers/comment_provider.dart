import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class CommentState {
  final List<CommentResponse> comments;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final int? recordId;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.recordId,
  });

  CommentState copyWith({
    List<CommentResponse>? comments,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    int? recordId,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      recordId: recordId ?? this.recordId,
    );
  }
}

class CommentNotifier extends StateNotifier<CommentState> {
  final CommentRepository _commentRepository;

  CommentNotifier(this._commentRepository) : super(const CommentState());

  /// 댓글 목록 로드
  Future<void> loadComments(int recordId) async {
    state = state.copyWith(isLoading: true, error: null, recordId: recordId);

    try {
      final comments = await _commentRepository.getComments(recordId);
      state = state.copyWith(
        comments: comments,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  /// 댓글 작성
  Future<bool> createComment(String content, {int? parentCommentId}) async {
    if (state.recordId == null) return false;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final comment = await _commentRepository.createComment(
        state.recordId!,
        CreateCommentRequest(
          content: content,
          parentCommentId: parentCommentId,
        ),
      );

      // 대댓글인 경우 부모 댓글의 replies에 추가
      if (parentCommentId != null) {
        final updatedComments = state.comments.map((c) {
          if (c.id == parentCommentId) {
            return c.copyWith(
              replies: [...c.replies, comment],
              replyCount: c.replyCount + 1,
            );
          }
          return c;
        }).toList();
        state = state.copyWith(
          comments: updatedComments,
          isSubmitting: false,
        );
      } else {
        // 일반 댓글인 경우 목록에 추가
        state = state.copyWith(
          comments: [...state.comments, comment],
          isSubmitting: false,
        );
      }

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.message,
      );
      return false;
    }
  }

  /// 댓글 수정
  Future<bool> updateComment(int commentId, String content) async {
    if (state.recordId == null) return false;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final updatedComment = await _commentRepository.updateComment(
        state.recordId!,
        commentId,
        UpdateCommentRequest(content: content),
      );

      final updatedComments = _updateCommentInList(state.comments, updatedComment);
      state = state.copyWith(
        comments: updatedComments,
        isSubmitting: false,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.message,
      );
      return false;
    }
  }

  /// 댓글 삭제
  Future<bool> deleteComment(int commentId) async {
    if (state.recordId == null) return false;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      await _commentRepository.deleteComment(state.recordId!, commentId);

      final updatedComments = _removeCommentFromList(state.comments, commentId);
      state = state.copyWith(
        comments: updatedComments,
        isSubmitting: false,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.message,
      );
      return false;
    }
  }

  /// 댓글 목록에서 특정 댓글 업데이트
  List<CommentResponse> _updateCommentInList(
    List<CommentResponse> comments,
    CommentResponse updated,
  ) {
    return comments.map((c) {
      if (c.id == updated.id) {
        return updated;
      }
      if (c.replies.isNotEmpty) {
        return c.copyWith(
          replies: _updateCommentInList(c.replies, updated),
        );
      }
      return c;
    }).toList();
  }

  /// 댓글 목록에서 특정 댓글 삭제
  List<CommentResponse> _removeCommentFromList(
    List<CommentResponse> comments,
    int commentId,
  ) {
    return comments
        .where((c) => c.id != commentId)
        .map((c) {
          if (c.replies.isNotEmpty) {
            return c.copyWith(
              replies: _removeCommentFromList(c.replies, commentId),
              replyCount: c.replies.any((r) => r.id == commentId)
                  ? c.replyCount - 1
                  : c.replyCount,
            );
          }
          return c;
        })
        .toList();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const CommentState();
  }
}

final commentProvider = StateNotifierProvider<CommentNotifier, CommentState>((ref) {
  return CommentNotifier(ref.read(commentRepositoryProvider));
});
