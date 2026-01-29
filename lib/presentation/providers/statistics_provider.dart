import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class StatisticsState {
  final UserStatistics? statistics;
  final bool isLoading;
  final String? error;

  const StatisticsState({
    this.statistics,
    this.isLoading = false,
    this.error,
  });

  StatisticsState copyWith({
    UserStatistics? statistics,
    bool? isLoading,
    String? error,
  }) {
    return StatisticsState(
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final StatisticsRepository _statisticsRepository;

  StatisticsNotifier(this._statisticsRepository)
      : super(const StatisticsState());

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statistics = await _statisticsRepository.getMyStatistics();
      state = state.copyWith(
        statistics: statistics,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier(ref.read(statisticsRepositoryProvider));
});
