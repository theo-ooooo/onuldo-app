import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/models.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/follow_repository.dart';

part 'user_provider.freezed.dart';

// User Search State
@freezed
class UserSearchState with _$UserSearchState {
  const factory UserSearchState({
    @Default([]) List<UserResponse> users,
    @Default(false) bool isLoading,
    String? error,
    @Default('') String query,
  }) = _UserSearchState;
}

// User Search Provider
class UserSearchNotifier extends StateNotifier<UserSearchState> {
  final UserRepository _userRepository;

  UserSearchNotifier(this._userRepository) : super(const UserSearchState());

  Future<void> searchUsers(String keyword) async {
    if (keyword.trim().isEmpty) {
      state = state.copyWith(users: [], query: '');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: keyword);

    try {
      final users = await _userRepository.searchUsers(keyword);
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearSearch() {
    state = const UserSearchState();
  }
}

final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, UserSearchState>((ref) {
  return UserSearchNotifier(ref.read(userRepositoryProvider));
});

// User Profile State
@freezed
class UserProfileState with _$UserProfileState {
  const factory UserProfileState({
    UserResponse? user,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isFollowing,
    @Default([]) List<FollowUserResponse> followers,
    @Default([]) List<FollowUserResponse> following,
  }) = _UserProfileState;
}

// User Profile Provider
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserRepository _userRepository;
  final FollowRepository _followRepository;

  UserProfileNotifier(this._userRepository, this._followRepository)
      : super(const UserProfileState());

  Future<void> loadUser(int userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _userRepository.getUser(userId);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadFollowers(int userId) async {
    try {
      final followers = await _followRepository.getFollowers(userId);
      state = state.copyWith(followers: followers);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> loadFollowing(int userId) async {
    try {
      final following = await _followRepository.getFollowing(userId);
      state = state.copyWith(following: following);
    } catch (e) {
      // Silently fail
    }
  }

  Future<bool> follow(int userId) async {
    try {
      await _followRepository.follow(userId);
      if (state.user != null) {
        state = state.copyWith(
          user: state.user!.copyWith(
            followerCount: state.user!.followerCount + 1,
          ),
          isFollowing: true,
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> unfollow(int userId) async {
    try {
      await _followRepository.unfollow(userId);
      if (state.user != null) {
        state = state.copyWith(
          user: state.user!.copyWith(
            followerCount: state.user!.followerCount - 1,
          ),
          isFollowing: false,
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void setFollowing(bool isFollowing) {
    state = state.copyWith(isFollowing: isFollowing);
  }

  void clear() {
    state = const UserProfileState();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier(
    ref.read(userRepositoryProvider),
    ref.read(followRepositoryProvider),
  );
});

// My Info Provider
final myInfoProvider = FutureProvider<UserResponse>((ref) async {
  final userRepository = ref.read(userRepositoryProvider);
  return userRepository.getMyInfo();
});
