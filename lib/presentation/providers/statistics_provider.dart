import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class StatisticsState {
  final WeeklyStatisticsResponse? weekly;
  final MonthlyStatisticsResponse? monthly;
  final DailyStatisticsResponse? today;
  final List<HobbyStatisticsResponse> hobbyStats;
  final StreakResponse? streak;
  final bool isLoading;
  final String? error;

  const StatisticsState({
    this.weekly,
    this.monthly,
    this.today,
    this.hobbyStats = const [],
    this.streak,
    this.isLoading = false,
    this.error,
  });

  StatisticsState copyWith({
    WeeklyStatisticsResponse? weekly,
    MonthlyStatisticsResponse? monthly,
    DailyStatisticsResponse? today,
    List<HobbyStatisticsResponse>? hobbyStats,
    StreakResponse? streak,
    bool? isLoading,
    String? error,
  }) {
    return StatisticsState(
      weekly: weekly ?? this.weekly,
      monthly: monthly ?? this.monthly,
      today: today ?? this.today,
      hobbyStats: hobbyStats ?? this.hobbyStats,
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 초기 상태로 리셋
  static const StatisticsState initial = StatisticsState();
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final StatisticsRepository _statisticsRepository;

  StatisticsNotifier(this._statisticsRepository)
      : super(const StatisticsState());

  /// 모든 통계 로드
  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      // 이번 주 월요일 계산
      final weekday = now.weekday; // 1 = Monday, 7 = Sunday
      final monday = now.subtract(Duration(days: weekday - 1));
      final weekStartDate = DateFormat('yyyy-MM-dd').format(monday);

      // 이번 달
      final yearMonth = DateFormat('yyyy-MM').format(now);

      // 병렬로 모든 API 호출 (각각 에러 처리)
      final weeklyFuture = _safeCall(() => _statisticsRepository.getWeeklyStatistics(weekStartDate));
      final monthlyFuture = _safeCall(() => _statisticsRepository.getMonthlyStatistics(yearMonth));
      final dailyFuture = _safeCallList(() => _statisticsRepository.getDailyStatistics(todayStr, todayStr));
      final hobbyFuture = _safeCallList(() => _statisticsRepository.getHobbyStatistics());
      final streakFuture = _safeCall(() => _statisticsRepository.getStreak());

      final results = await Future.wait([
        weeklyFuture,
        monthlyFuture,
        dailyFuture,
        hobbyFuture,
        streakFuture,
      ]);

      final weekly = results[0] as WeeklyStatisticsResponse?;
      final monthly = results[1] as MonthlyStatisticsResponse?;
      final dailyList = results[2] as List<DailyStatisticsResponse>;
      final hobbyStats = results[3] as List<HobbyStatisticsResponse>;
      final streak = results[4] as StreakResponse?;

      // 오늘 통계 추출
      DailyStatisticsResponse? today;
      if (dailyList.isNotEmpty) {
        today = dailyList.first;
      }

      state = state.copyWith(
        weekly: weekly,
        monthly: monthly,
        today: today,
        hobbyStats: hobbyStats,
        streak: streak,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '통계를 불러오는데 실패했습니다.',
      );
    }
  }

  /// null을 반환할 수 있는 API 호출 래퍼
  Future<T?> _safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return null;
    }
  }

  /// 빈 리스트를 반환할 수 있는 API 호출 래퍼
  Future<List<T>> _safeCallList<T>(Future<List<T>> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return <T>[];
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 상태 초기화 (로그아웃 시 호출)
  void reset() {
    state = StatisticsState.initial;
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier(ref.read(statisticsRepositoryProvider));
});
