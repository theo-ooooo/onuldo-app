import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

@RoutePage()
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsProvider.notifier).loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const PageHeader(
              title: '통계',
            ),

            const SizedBox(height: 20),

            // Tab selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  AppChip(
                    label: '오늘',
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  AppChip(
                    label: '이번 주',
                    isSelected: _selectedTabIndex == 1,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                  const SizedBox(width: 8),
                  AppChip(
                    label: '이번 달',
                    isSelected: _selectedTabIndex == 2,
                    onTap: () => setState(() => _selectedTabIndex = 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _buildBody(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(StatisticsState state) {
    if (state.isLoading) {
      return const Center(child: LoadingIndicator(size: 48));
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(statisticsProvider.notifier).loadStatistics(),
      );
    }

    // 데이터가 하나도 없을 때
    final hasNoData = state.today == null &&
                      state.weekly == null &&
                      state.monthly == null &&
                      state.hobbyStats.isEmpty;

    if (hasNoData) {
      return const _EmptyStatisticsView();
    }

    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        _DailyStatisticsView(
          today: state.today,
          hobbyStats: state.hobbyStats,
          streak: state.streak,
        ),
        _WeeklyStatisticsView(
          weekly: state.weekly,
          hobbyStats: state.hobbyStats,
        ),
        _MonthlyStatisticsView(
          monthly: state.monthly,
          hobbyStats: state.hobbyStats,
        ),
      ],
    );
  }
}

class _EmptyStatisticsView extends StatelessWidget {
  const _EmptyStatisticsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.bar_chart_outlined,
              size: 28,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 기록이 없습니다',
            style: typography.body.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '타이머로 활동을 기록해보세요',
            style: typography.footnote.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStatisticsView extends StatelessWidget {
  final DailyStatisticsResponse? today;
  final List<HobbyStatisticsResponse> hobbyStats;
  final StreakResponse? streak;

  const _DailyStatisticsView({
    required this.today,
    required this.hobbyStats,
    this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _SummaryCard(
            totalSeconds: today?.totalDurationSeconds ?? 0,
            recordCount: today?.recordCount ?? 0,
            label: '오늘',
          ),
          if (streak != null && streak!.currentStreak > 0) ...[
            const SizedBox(height: 16),
            _StreakCard(streak: streak!),
          ],
          const SizedBox(height: 20),
          if (hobbyStats.isNotEmpty)
            _HobbyBreakdownCard(hobbies: hobbyStats),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _WeeklyStatisticsView extends StatelessWidget {
  final WeeklyStatisticsResponse? weekly;
  final List<HobbyStatisticsResponse> hobbyStats;

  const _WeeklyStatisticsView({
    required this.weekly,
    required this.hobbyStats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _SummaryCard(
            totalSeconds: weekly?.totalDurationSeconds ?? 0,
            recordCount: weekly?.recordCount ?? 0,
            label: '이번 주',
          ),
          if (weekly != null && weekly!.dailyStatistics.isNotEmpty) ...[
            const SizedBox(height: 20),
            _WeeklyChartCard(dailyStats: weekly!.dailyStatistics),
          ],
          const SizedBox(height: 20),
          if (hobbyStats.isNotEmpty)
            _HobbyBreakdownCard(hobbies: hobbyStats),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MonthlyStatisticsView extends StatelessWidget {
  final MonthlyStatisticsResponse? monthly;
  final List<HobbyStatisticsResponse> hobbyStats;

  const _MonthlyStatisticsView({
    required this.monthly,
    required this.hobbyStats,
  });

  @override
  Widget build(BuildContext context) {
    final label = monthly?.yearMonth != null
        ? '${monthly!.yearMonth.split('-')[1]}월'
        : '이번 달';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _SummaryCard(
            totalSeconds: monthly?.totalDurationSeconds ?? 0,
            recordCount: monthly?.recordCount ?? 0,
            label: label,
          ),
          const SizedBox(height: 20),
          if (hobbyStats.isNotEmpty)
            _HobbyBreakdownCard(hobbies: hobbyStats),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int totalSeconds;
  final int recordCount;
  final String label;

  const _SummaryCard({
    required this.totalSeconds,
    required this.recordCount,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Period label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: typography.footnote.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Total duration
          Text(
            DurationFormatter.formatHumanReadable(
              Duration(seconds: totalSeconds),
            ),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: colors.textPrimary,
              letterSpacing: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),

          // Record count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.timerRunning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$recordCount개의 기록',
                style: typography.subhead.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final StreakResponse streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.timerRunning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: colors.timerRunning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${streak.currentStreak}일 연속 기록 중',
                  style: typography.headline,
                ),
                Text(
                  '최장 기록: ${streak.longestStreak}일',
                  style: typography.footnote.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  final List<DailyStatisticsResponse> dailyStats;

  const _WeeklyChartCard({required this.dailyStats});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // 최대 시간 계산 (최소 1시간 = 3600초)
    final maxSeconds = dailyStats.fold<int>(
      3600,
      (max, stat) => stat.totalDurationSeconds > max ? stat.totalDurationSeconds : max,
    );

    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '일별 활동',
            style: typography.headline,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final stat = index < dailyStats.length ? dailyStats[index] : null;
                final seconds = stat?.totalDurationSeconds ?? 0;
                final height = maxSeconds > 0 ? (seconds / maxSeconds) * 80 : 0.0;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height.clamp(4.0, 80.0),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: seconds > 0 ? colors.textPrimary : colors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weekDays[index],
                        style: typography.caption2.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HobbyBreakdownCard extends StatelessWidget {
  final List<HobbyStatisticsResponse> hobbies;

  const _HobbyBreakdownCard({required this.hobbies});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // 총 시간 계산
    final totalSeconds = hobbies.fold<int>(
      0,
      (sum, hobby) => sum + hobby.totalDurationSeconds,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '취미별 누적 시간',
            style: typography.headline,
          ),
          const SizedBox(height: 16),
          ...hobbies.asMap().entries.map((entry) {
            final index = entry.key;
            final hobby = entry.value;
            final isLast = index == hobbies.length - 1;
            final percentage = totalSeconds > 0
                ? (hobby.totalDurationSeconds / totalSeconds * 100)
                : 0.0;
            return _HobbyStatItem(
              hobby: hobby,
              percentage: percentage,
              showDivider: !isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _HobbyStatItem extends StatelessWidget {
  final HobbyStatisticsResponse hobby;
  final double percentage;
  final bool showDivider;

  const _HobbyStatItem({
    required this.hobby,
    required this.percentage,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.timerRunning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        hobby.hobbyName,
                        style: typography.body,
                      ),
                    ],
                  ),
                  Text(
                    DurationFormatter.formatHumanReadable(
                      Duration(seconds: hobby.totalDurationSeconds),
                    ),
                    style: typography.subhead.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: colors.surfaceSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 0.5,
            color: colors.separatorOpaque,
          ),
      ],
    );
  }
}
