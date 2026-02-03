import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class FeedState {
  final List<FeedItemResponse> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final FeedType feedType;
  final SortType sortType;
  final int currentPage;
  final bool hasMore;

  const FeedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.feedType = FeedType.all,
    this.sortType = SortType.latest,
    this.currentPage = 0,
    this.hasMore = true,
  });

  FeedState copyWith({
    List<FeedItemResponse>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    FeedType? feedType,
    SortType? sortType,
    int? currentPage,
    bool? hasMore,
  }) {
    return FeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      feedType: feedType ?? this.feedType,
      sortType: sortType ?? this.sortType,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final FeedRepository _feedRepository;
  final ReactionRepository _reactionRepository;

  FeedNotifier(this._feedRepository, this._reactionRepository)
      : super(const FeedState());

  Future<void> loadFeed({bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 0 : state.currentPage;
    state = state.copyWith(
      isLoading: refresh || page == 0,
      isLoadingMore: !refresh && page > 0,
      error: null,
    );

    try {
      const pageSize = 20;
      final items = state.feedType == FeedType.all
          ? await _feedRepository.getFeed(
              page: page,
              size: pageSize,
              sort: state.sortType,
            )
          : await _feedRepository.getFollowingFeed(
              page: page,
              size: pageSize,
              sort: state.sortType,
            );

      // 각 레코드에 대해 내 리액션 및 리액션 카운트 조회 (병렬 처리)
      final itemsWithReactions = await Future.wait(
        items.map((item) async {
          try {
            // 내 리액션 조회
            final myReactions = await _reactionRepository.getMyReactions(item.recordId);
            final emojiTypes = myReactions.map((r) => r.emojiType).toList();
            
            // 리액션 카운트 조회
            final reactionCount = await _reactionRepository.getReactionCount(item.recordId);
            
            return item.copyWith(
              myReactions: emojiTypes,
              reactionCounts: reactionCount.counts,
            );
          } catch (e) {
            // 리액션 조회 실패 시 기존 아이템 반환 (에러 무시)
            return item;
          }
        }),
      );

      final newItems = refresh || page == 0
          ? itemsWithReactions
          : [...state.items, ...itemsWithReactions];

      state = state.copyWith(
        items: newItems,
        isLoading: false,
        isLoadingMore: false,
        currentPage: page + 1,
        hasMore: items.length >= pageSize,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.message,
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    await loadFeed();
  }

  Future<void> refresh() async {
    await loadFeed(refresh: true);
  }

  void changeFeedType(FeedType type) {
    if (state.feedType != type) {
      state = state.copyWith(
        feedType: type,
        items: [],
        currentPage: 0,
        hasMore: true,
      );
      loadFeed();
    }
  }

  void changeSortType(SortType type) {
    if (state.sortType != type) {
      state = state.copyWith(
        sortType: type,
        items: [],
        currentPage: 0,
        hasMore: true,
      );
      loadFeed();
    }
  }

  Future<void> addReaction(int recordId, EmojiType emojiType) async {
    try {
      // 이미 리액션이 있는지 확인
      final item = state.items.firstWhere(
        (i) => i.recordId == recordId,
        orElse: () => throw Exception('Item not found'),
      );

      if (item.hasMyReaction(emojiType)) {
        // 이미 리액션이 있으면 추가하지 않음
        return;
      }

      await _reactionRepository.addReaction(
        recordId,
        AddReactionRequest(emojiType: emojiType),
      );

      // 내 리액션 목록 및 리액션 카운트 다시 조회하여 정확한 상태 업데이트
      final myReactions = await _reactionRepository.getMyReactions(recordId);
      final emojiTypes = myReactions.map((r) => r.emojiType).toList();
      final reactionCount = await _reactionRepository.getReactionCount(recordId);

      // Update local state
      final updatedItems = state.items.map((item) {
        if (item.recordId == recordId) {
          return item.copyWith(
            myReactions: emojiTypes,
            reactionCounts: reactionCount.counts,
          );
        }
        return item;
      }).toList();

      state = state.copyWith(items: updatedItems);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> removeReaction(int recordId, EmojiType emojiType) async {
    try {
      // 리액션이 없는지 확인
      final item = state.items.firstWhere(
        (i) => i.recordId == recordId,
        orElse: () => throw Exception('Item not found'),
      );

      if (!item.hasMyReaction(emojiType)) {
        // 리액션이 없으면 제거하지 않음
        return;
      }

      await _reactionRepository.removeReaction(recordId, emojiType);

      // 내 리액션 목록 및 리액션 카운트 다시 조회하여 정확한 상태 업데이트
      final myReactions = await _reactionRepository.getMyReactions(recordId);
      final emojiTypes = myReactions.map((r) => r.emojiType).toList();
      final reactionCount = await _reactionRepository.getReactionCount(recordId);

      // Update local state
      final updatedItems = state.items.map((item) {
        if (item.recordId == recordId) {
          return item.copyWith(
            myReactions: emojiTypes,
            reactionCounts: reactionCount.counts,
          );
        }
        return item;
      }).toList();

      state = state.copyWith(items: updatedItems);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  /// Toggle reaction - add if not present, remove if present
  Future<void> toggleReaction(int recordId, EmojiType emojiType) async {
    // 최신 상태에서 아이템 찾기
    final item = state.items.firstWhere(
      (i) => i.recordId == recordId,
      orElse: () => throw Exception('Item not found'),
    );

    // 현재 상태에 따라 토글
    if (item.hasMyReaction(emojiType)) {
      await removeReaction(recordId, emojiType);
    } else {
      await addReaction(recordId, emojiType);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 상태 초기화 (로그아웃 시 호출)
  void reset() {
    state = const FeedState();
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(
    ref.read(feedRepositoryProvider),
    ref.read(reactionRepositoryProvider),
  );
});
