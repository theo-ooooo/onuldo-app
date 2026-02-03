import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class HobbyListState {
  final List<HobbyResponse> hobbies;
  final bool isLoading;
  final String? error;
  final HobbyResponse? selectedHobby;

  const HobbyListState({
    this.hobbies = const [],
    this.isLoading = false,
    this.error,
    this.selectedHobby,
  });

  HobbyListState copyWith({
    List<HobbyResponse>? hobbies,
    bool? isLoading,
    String? error,
    HobbyResponse? selectedHobby,
    bool clearSelectedHobby = false,
  }) {
    return HobbyListState(
      hobbies: hobbies ?? this.hobbies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedHobby: clearSelectedHobby ? null : (selectedHobby ?? this.selectedHobby),
    );
  }
}

class HobbyNotifier extends StateNotifier<HobbyListState> {
  final HobbyRepository _hobbyRepository;

  HobbyNotifier(this._hobbyRepository) : super(const HobbyListState());

  Future<void> loadHobbies() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final hobbies = await _hobbyRepository.getHobbies();
      state = state.copyWith(
        hobbies: hobbies,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  Future<bool> createHobby(CreateHobbyRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final hobby = await _hobbyRepository.createHobby(request);
      state = state.copyWith(
        hobbies: [...state.hobbies, hobby],
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  Future<bool> updateHobby(int id, UpdateHobbyRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedHobby = await _hobbyRepository.updateHobby(id, request);
      final hobbies = state.hobbies.map((hobby) {
        if (hobby.id == id) {
          return updatedHobby;
        }
        return hobby;
      }).toList();

      state = state.copyWith(
        hobbies: hobbies,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  Future<bool> deleteHobby(int id) async {
    // 삭제 중에는 로딩 상태를 표시하지 않음 (즉시 UI 업데이트)
    try {
      await _hobbyRepository.deleteHobby(id);
      final hobbies = state.hobbies.where((hobby) => hobby.id != id).toList();
      state = state.copyWith(
        hobbies: hobbies,
        isLoading: false,
        error: null,
        selectedHobby: state.selectedHobby?.id == id ? null : state.selectedHobby,
        clearSelectedHobby: state.selectedHobby?.id == id,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  void selectHobby(HobbyResponse hobby) {
    state = state.copyWith(selectedHobby: hobby);
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedHobby: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 상태 초기화 (로그아웃 시 호출)
  void reset() {
    state = const HobbyListState();
  }
}

final hobbyProvider = StateNotifierProvider<HobbyNotifier, HobbyListState>((ref) {
  return HobbyNotifier(ref.read(hobbyRepositoryProvider));
});
