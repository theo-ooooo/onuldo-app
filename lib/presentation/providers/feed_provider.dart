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

      final newItems = refresh || page == 0
          ? items
          : [...state.items, ...items];

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
      await _reactionRepository.addReaction(
        AddReactionRequest(recordId: recordId, emojiType: emojiType),
      );

      // Update local state
      final updatedItems = state.items.map((item) {
        if (item.id == recordId) {
          return item.copyWith(
            myReaction: emojiType,
            reactionCount: item.reactionCount + 1,
          );
        }
        return item;
      }).toList();

      state = state.copyWith(items: updatedItems);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> removeReaction(int recordId) async {
    try {
      await _reactionRepository.removeReaction(recordId);

      // Update local state
      final updatedItems = state.items.map((item) {
        if (item.id == recordId) {
          return item.copyWith(
            myReaction: null,
            reactionCount: item.reactionCount > 0 ? item.reactionCount - 1 : 0,
          );
        }
        return item;
      }).toList();

      state = state.copyWith(items: updatedItems);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(
    ref.read(feedRepositoryProvider),
    ref.read(reactionRepositoryProvider),
  );
});
