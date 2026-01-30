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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  const AppLogoIcon(size: 44),
                  const SizedBox(width: 12),
                  Text(
                    '통계',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tab selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _TabChip(
                    label: '오늘',
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                  const SizedBox(width: 12),
                  _TabChip(
                    label: '이번 주',
                    isSelected: _selectedTabIndex == 1,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                  const SizedBox(width: 12),
                  _TabChip(
                    label: '이번 달',
                    isSelected: _selectedTabIndex == 2,
                    onTap: () => setState(() => _selectedTabIndex = 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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

    if (state.statistics == null) {
      return _EmptyStatisticsView();
    }

    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        _DailyStatisticsView(statistics: state.statistics!),
        _WeeklyStatisticsView(statistics: state.statistics!),
        _MonthlyStatisticsView(statistics: state.statistics!),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.background : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _EmptyStatisticsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.bar_chart_outlined,
              size: 36,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '통계 데이터가 없습니다',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            DurationFormatter.formatHumanReadable(
              Duration(seconds: totalSeconds),
            ),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.timerRunning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$recordCount개의 기록',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '취미별 활동',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ...hobbies.map((hobby) => _HobbyStatItem(hobby: hobby)),
        ],
      ),
    );
  }
}

class _HobbyStatItem extends StatelessWidget {
  final HobbyStatistics hobby;

  const _HobbyStatItem({required this.hobby});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                      color: AppColors.timerRunning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hobby.hobbyName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                DurationFormatter.formatHumanReadable(
                  Duration(seconds: hobby.totalDurationSeconds),
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hobby.percentage / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
