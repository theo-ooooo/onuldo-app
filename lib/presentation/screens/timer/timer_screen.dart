import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../router/app_router.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hobbyProvider.notifier).loadHobbies();
      ref.read(timerProvider.notifier).loadCurrentTimer();
    });
  }

  void _showHobbySelector() {
    final hobbies = ref.read(hobbyProvider).hobbies;
    if (hobbies.isEmpty) {
      _showAddHobbyDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _HobbySelectorSheet(
        hobbies: hobbies,
        selectedHobby: ref.read(hobbyProvider).selectedHobby,
        onSelect: (hobby) {
          ref.read(hobbyProvider.notifier).selectHobby(hobby);
          Navigator.pop(context);
        },
        onAddNew: () {
          Navigator.pop(context);
          _showAddHobbyDialog();
        },
      ),
    );
  }

  void _showAddHobbyDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 취미 추가'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: '취미 이름',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final success = await ref.read(hobbyProvider.notifier).createHobby(
                CreateHobbyRequest(name: nameController.text.trim()),
              );

              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _startTimer() async {
    final selectedHobby = ref.read(hobbyProvider).selectedHobby;
    if (selectedHobby == null) {
      _showHobbySelector();
      return;
    }

    await ref.read(timerProvider.notifier).startTimer(selectedHobby.id);
  }

  Future<void> _stopTimer() async {
    final selectedHobby = ref.read(hobbyProvider).selectedHobby;
    final result = await ref.read(timerProvider.notifier).stopTimer();
    if (result != null && mounted) {
      context.push(
        AppRoutes.createRecord,
        extra: {
          'timerId': result.id,
          'hobbyId': result.hobbyId,
          'hobbyName': selectedHobby?.name ?? '',
          'durationSeconds': result.durationSeconds,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hobbyState = ref.watch(hobbyProvider);
    final timerState = ref.watch(timerProvider);

    final timerColor = switch (timerState.status) {
      LocalTimerStatus.running => AppColors.timerRunning,
      LocalTimerStatus.paused => AppColors.timerPaused,
      LocalTimerStatus.idle => AppColors.primary,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘도'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Hobby selector
              GestureDetector(
                onTap: timerState.status == LocalTimerStatus.idle
                    ? _showHobbySelector
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: hobbyState.selectedHobby != null
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hobbyState.selectedHobby?.name ?? '취미를 선택하세요',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: hobbyState.selectedHobby != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      if (timerState.status == LocalTimerStatus.idle) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Timer display
              TimerCircle(
                seconds: timerState.elapsedSeconds,
                color: timerColor,
              ),

              const SizedBox(height: 16),

              // Status text
              Text(
                switch (timerState.status) {
                  LocalTimerStatus.running => '진행 중',
                  LocalTimerStatus.paused => '일시정지',
                  LocalTimerStatus.idle => '시작하기',
                },
                style: AppTextStyles.bodyLarge.copyWith(
                  color: timerColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Timer controls
              TimerControls(
                status: timerState.status,
                onStart: _startTimer,
                onPause: () => ref.read(timerProvider.notifier).pauseTimer(),
                onResume: () => ref.read(timerProvider.notifier).resumeTimer(),
                onStop: _stopTimer,
                isLoading: timerState.isLoading,
                canStart: hobbyState.selectedHobby != null,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _HobbySelectorSheet extends StatelessWidget {
  final List<HobbyResponse> hobbies;
  final HobbyResponse? selectedHobby;
  final ValueChanged<HobbyResponse> onSelect;
  final VoidCallback onAddNew;

  const _HobbySelectorSheet({
    required this.hobbies,
    this.selectedHobby,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '취미 선택',
              style: AppTextStyles.h4,
            ),
          ),
          const Divider(),
          ...hobbies.map((hobby) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(hobby.name),
                trailing: selectedHobby?.id == hobby.id
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => onSelect(hobby),
              )),
          const Divider(),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.textSecondary,
              ),
            ),
            title: const Text('새 취미 추가'),
            onTap: onAddNew,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
