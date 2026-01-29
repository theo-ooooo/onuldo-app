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
    final daily = statistics.daily;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SummaryCard(
            totalSeconds: daily.totalDurationSeconds,
            recordCount: daily.recordCount,
            label: '오늘',
          ),
          const SizedBox(height: 24),
          if (statistics.hobbyStats.isNotEmpty)
            _HobbyBreakdownCard(hobbies: statistics.hobbyStats),
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
    final weekly = statistics.weekly;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SummaryCard(
            totalSeconds: weekly.totalDurationSeconds,
            recordCount: weekly.recordCount,
            label: '이번 주',
          ),
          const SizedBox(height: 24),
          if (statistics.hobbyStats.isNotEmpty)
            _HobbyBreakdownCard(hobbies: statistics.hobbyStats),
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
    final monthly = statistics.monthly;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SummaryCard(
            totalSeconds: monthly.totalDurationSeconds,
            recordCount: monthly.recordCount,
            label: '${monthly.month}월',
          ),
          const SizedBox(height: 24),
          if (statistics.hobbyStats.isNotEmpty)
            _HobbyBreakdownCard(hobbies: statistics.hobbyStats),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DurationFormatter.formatHumanReadable(
              Duration(seconds: totalSeconds),
            ),
            style: AppTextStyles.h1,
          ),
          const SizedBox(height: 8),
          Text(
            '$recordCount개의 기록',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
                          Duration(seconds: hobby.totalDurationSeconds),
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
