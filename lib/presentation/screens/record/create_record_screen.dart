import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';

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
    if (widget.timerId == null || widget.hobbyId == null || widget.durationSeconds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('기록 정보가 올바르지 않습니다'),
          backgroundColor: AppColors.error,
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
          content: Text('기록이 저장되었습니다'),
          backgroundColor: AppColors.timerRunning,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(recordProvider).error;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(recordProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '기록 저장',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: recordState.isLoading ? null : _saveRecord,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: recordState.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : Text(
                              '저장',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          // Hobby name chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.timerRunning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                  widget.hobbyName ?? '취미',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.timerRunning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            DurationFormatter.formatSeconds(widget.durationSeconds ?? 0),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w200,
                              color: AppColors.textPrimary,
                              letterSpacing: 2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DurationFormatter.formatHumanReadable(
                              Duration(seconds: widget.durationSeconds ?? 0),
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Memo field
                    Text(
                      '메모',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _memoController,
                        maxLines: 4,
                        maxLength: 500,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: '오늘의 활동은 어땠나요?',
                          hintStyle: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          counterStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Visibility selector
                    Text(
                      '공개 범위',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: Visibility.values.map((v) {
                        final isSelected = _visibility == v;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
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

                    const SizedBox(height: 12),
                    Text(
                      _visibilityDescription(_visibility),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
