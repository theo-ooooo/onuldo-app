import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsProvider.notifier).loadStatistics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '오늘'),
            Tab(text: '이번 주'),
            Tab(text: '이번 달'),
          ],
        ),
      ),
      body: _buildBody(state),
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

    if (state.statistics == null) {
      return const EmptyView(
        message: '통계 데이터가 없습니다',
        icon: Icons.bar_chart_outlined,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _DailyStatisticsView(statistics: state.statistics!),
        _WeeklyStatisticsView(statistics: state.statistics!),
        _MonthlyStatisticsView(statistics: state.statistics!),
      ],
    );
  }
}

class _DailyStatisticsView extends StatelessWidget {
  final UserStatistics statistics;

  const _DailyStatisticsView({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final today = statistics.today;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SummaryCard(
            totalSeconds: today.totalSeconds,
            recordCount: today.recordCount,
            label: '오늘',
          ),
          const SizedBox(height: 24),
          if (today.hobbyBreakdown != null && today.hobbyBreakdown!.isNotEmpty)
            _HobbyBreakdownCard(hobbies: today.hobbyBreakdown!),
        ],
      ),
    );
  }
}

class _WeeklyStatisticsView extends StatelessWidget {
  final UserStatistics statistics;

  const _WeeklyStatisticsView({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final week = statistics.thisWeek;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SummaryCard(
            totalSeconds: week.totalSeconds,
            recordCount: week.recordCount,
            label: '이번 주',
          ),
          const SizedBox(height: 24),
          _WeeklyChartCard(dailyBreakdown: week.dailyBreakdown),
          const SizedBox(height: 24),
          if (statistics.hobbyBreakdown.isNotEmpty)
            _HobbyBreakdownCard(hobbies: statistics.hobbyBreakdown),
        ],
      ),
    );
  }
}

class _MonthlyStatisticsView extends StatelessWidget {
  final UserStatistics statistics;

  const _MonthlyStatisticsView({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final month = statistics.thisMonth;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SummaryCard(
            totalSeconds: month.totalSeconds,
            recordCount: month.recordCount,
            label: '${month.month}월',
          ),
          const SizedBox(height: 24),
          _OverviewCard(statistics: statistics),
          const SizedBox(height: 24),
          if (statistics.hobbyBreakdown.isNotEmpty)
            _HobbyBreakdownCard(hobbies: statistics.hobbyBreakdown),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DurationFormatter.formatHumanReadable(
              Duration(seconds: totalSeconds),
            ),
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$recordCount개의 기록',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  final List<DailyStatistics> dailyBreakdown;

  const _WeeklyChartCard({required this.dailyBreakdown});

  @override
  Widget build(BuildContext context) {
    final maxSeconds = dailyBreakdown.isEmpty
        ? 1
        : dailyBreakdown
            .map((d) => d.totalSeconds)
            .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('일별 활동', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyBreakdown.map((day) {
                final height = maxSeconds > 0
                    ? (day.totalSeconds / maxSeconds) * 100
                    : 0.0;

                return Column(
                  children: [
                    Container(
                      width: 32,
                      height: height.clamp(4, 100),
                      decoration: BoxDecoration(
                        color: day.totalSeconds > 0
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDayLabel(day.date),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayLabel(String date) {
    try {
      final dateTime = DateTime.parse(date);
      const days = ['월', '화', '수', '목', '금', '토', '일'];
      return days[dateTime.weekday - 1];
    } catch (e) {
      return '';
    }
  }
}

class _OverviewCard extends StatelessWidget {
  final UserStatistics statistics;

  const _OverviewCard({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('전체 현황', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: '총 기록',
                    value: '${statistics.totalRecords}개',
                    icon: Icons.event_note_outlined,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '총 시간',
                    value: DurationFormatter.formatHumanReadable(
                      Duration(seconds: statistics.totalSeconds),
                    ),
                    icon: Icons.timer_outlined,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '취미 개수',
                    value: '${statistics.totalHobbies}개',
                    icon: Icons.palette_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.labelLarge),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _HobbyBreakdownCard extends StatelessWidget {
  final List<HobbyStatistics> hobbies;

  const _HobbyBreakdownCard({required this.hobbies});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('취미별 활동', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            ...hobbies.map((hobby) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hobby.hobbyName, style: AppTextStyles.labelLarge),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: hobby.percentage / 100,
                                backgroundColor: AppColors.surfaceVariant,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        DurationFormatter.formatHumanReadable(
                          Duration(seconds: hobby.totalSeconds),
                        ),
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
