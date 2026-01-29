import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class CreateRecordScreen extends ConsumerStatefulWidget {
  final int? hobbyId;
  final String? hobbyName;
  final int? durationSeconds;

  const CreateRecordScreen({
    super.key,
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
    if (widget.hobbyId == null || widget.durationSeconds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록 정보가 올바르지 않습니다')),
      );
      return;
    }

    final record = await ref.read(recordProvider.notifier).createRecord(
          CreateRecordRequest(
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
        const SnackBar(content: Text('기록이 저장되었습니다')),
      );
      context.pop();
    } else {
      final error = ref.read(recordProvider).error;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(recordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('기록 저장'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: recordState.isLoading ? null : _saveRecord,
            child: recordState.isLoading
                ? const LoadingIndicator(size: 20)
                : const Text('저장'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
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
                    widget.hobbyName ?? '취미',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DurationFormatter.formatSeconds(widget.durationSeconds ?? 0),
                    style: AppTextStyles.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DurationFormatter.formatHumanReadable(
                      Duration(seconds: widget.durationSeconds ?? 0),
                    ),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Memo field
            Text(
              '메모',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _memoController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: '오늘의 활동은 어땠나요?',
              ),
            ),

            const SizedBox(height: 24),

            // Visibility selector
            Text(
              '공개 범위',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Visibility.values.map((v) {
                final isSelected = _visibility == v;
                return ChoiceChip(
                  label: Text(_visibilityLabel(v)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _visibility = v;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 8),
            Text(
              _visibilityDescription(_visibility),
              style: AppTextStyles.bodySmall,
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
