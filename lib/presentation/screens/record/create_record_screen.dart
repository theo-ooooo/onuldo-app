import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';

@RoutePage()
class CreateRecordScreen extends ConsumerStatefulWidget {
  final int? timerId;
  final int? hobbyId;
  final String? hobbyName;
  final int? durationSeconds;

  const CreateRecordScreen({
    super.key,
    this.timerId,
    this.hobbyId,
    this.hobbyName,
    this.durationSeconds,
  });

  @override
  ConsumerState<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends ConsumerState<CreateRecordScreen> {
  final _memoController = TextEditingController();
  Visibility _visibility = Visibility.public;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    final colors = context.colors;

    if (widget.timerId == null || widget.hobbyId == null || widget.durationSeconds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('기록 정보가 올바르지 않습니다'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    final record = await ref.read(recordProvider.notifier).createRecord(
          CreateRecordRequest(
            timerId: widget.timerId!,
            hobbyId: widget.hobbyId!,
            durationSeconds: widget.durationSeconds!,
            memo: _memoController.text.trim().isEmpty
                ? null
                : _memoController.text.trim(),
            visibility: _visibility,
          ),
        );

    if (record != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('기록이 저장되었습니다'),
          backgroundColor: colors.timerRunning,
        ),
      );
      context.router.maybePop();
    } else {
      final error = ref.read(recordProvider).error;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(recordProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.router.maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.close,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '기록 저장',
                    style: typography.title3,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: recordState.isLoading ? null : _saveRecord,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.textPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: recordState.isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.background,
                              ),
                            )
                          : Text(
                              '저장',
                              style: typography.subhead.copyWith(
                                color: colors.background,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Hobby name chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.timerRunning.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                  widget.hobbyName ?? '취미',
                                  style: typography.footnote.copyWith(
                                    color: colors.timerRunning,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            DurationFormatter.formatSeconds(widget.durationSeconds ?? 0),
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w200,
                              color: colors.textPrimary,
                              letterSpacing: 2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DurationFormatter.formatHumanReadable(
                              Duration(seconds: widget.durationSeconds ?? 0),
                            ),
                            style: typography.subhead.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Memo field
                    Text(
                      '메모',
                      style: typography.headline.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _memoController,
                        maxLines: 4,
                        maxLength: 500,
                        style: typography.body,
                        decoration: InputDecoration(
                          hintText: '오늘의 활동은 어땠나요?',
                          hintStyle: typography.body.copyWith(
                            color: colors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          counterStyle: typography.caption1.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Visibility selector
                    Text(
                      '공개 범위',
                      style: typography.headline.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: Visibility.values.map((v) {
                        final isSelected = _visibility == v;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _VisibilityChip(
                            label: _visibilityLabel(v),
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _visibility = v;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      _visibilityDescription(_visibility),
                      style: typography.footnote.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _visibilityLabel(Visibility v) {
    return switch (v) {
      Visibility.public => '전체 공개',
      Visibility.followers => '팔로워만',
      Visibility.private => '나만 보기',
    };
  }

  String _visibilityDescription(Visibility v) {
    return switch (v) {
      Visibility.public => '모든 사람이 이 기록을 볼 수 있습니다',
      Visibility.followers => '나를 팔로우하는 사람만 이 기록을 볼 수 있습니다',
      Visibility.private => '나만 이 기록을 볼 수 있습니다',
    };
  }
}

class _VisibilityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VisibilityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.textPrimary : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.textPrimary : colors.separatorOpaque,
          ),
        ),
        child: Text(
          label,
          style: typography.subhead.copyWith(
            color: isSelected ? colors.background : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
