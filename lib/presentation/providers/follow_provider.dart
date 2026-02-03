import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class FollowState {
  final FollowCountResponse? count;
  final List<FollowUserResponse> followers;
  final List<FollowUserResponse> following;
  final bool isLoading;
  final String? error;

  const FollowState({
    this.count,
    this.followers = const [],
    this.following = const [],
    this.isLoading = false,
    this.error,
  });

  FollowState copyWith({
    FollowCountResponse? count,
    List<FollowUserResponse>? followers,
    List<FollowUserResponse>? following,
    bool? isLoading,
    String? error,
  }) {
    return FollowState(
      count: count ?? this.count,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FollowNotifier extends StateNotifier<FollowState> {
  final FollowRepository _followRepository;

  FollowNotifier(this._followRepository) : super(const FollowState());

  Future<void> loadFollowCount(int userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final count = await _followRepository.getFollowCount(userId);
      state = state.copyWith(
        count: count,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  Future<void> loadFollowers(int userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final followers = await _followRepository.getFollowers(userId);
      state = state.copyWith(
        followers: followers,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  Future<void> loadFollowing(int userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final following = await _followRepository.getFollowing(userId);
      state = state.copyWith(
        following: following,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  Future<bool> follow(int targetUserId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _followRepository.follow(targetUserId);

      // Update count if available
      if (state.count != null) {
        state = state.copyWith(
          count: FollowCountResponse(
            followerCount: state.count!.followerCount,
            followingCount: state.count!.followingCount + 1,
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  Future<bool> unfollow(int targetUserId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _followRepository.unfollow(targetUserId);

      // Update count if available
      if (state.count != null) {
        state = state.copyWith(
          count: FollowCountResponse(
            followerCount: state.count!.followerCount,
            followingCount: state.count!.followingCount > 0
                ? state.count!.followingCount - 1
                : 0,
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 상태 초기화 (로그아웃 시 호출)
  void reset() {
    state = const FollowState();
  }
}

final followProvider = StateNotifierProvider<FollowNotifier, FollowState>((ref) {
  return FollowNotifier(ref.read(followRepositoryProvider));
});
