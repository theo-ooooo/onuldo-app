import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';

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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          '새 취미 추가',
          style: AppTextStyles.h4,
        ),
        content: TextField(
          controller: nameController,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: '취미 이름을 입력하세요',
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final success = await ref.read(hobbyProvider.notifier).createHobby(
                CreateHobbyRequest(name: nameController.text.trim()),
              );

              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              '추가',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
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

    final isRunning = timerState.status == LocalTimerStatus.running;
    final isIdle = timerState.status == LocalTimerStatus.idle;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header with logo
              const AppLogoWithText(iconSize: 44, fontSize: 20),

              const SizedBox(height: 40),

              // Hobby selector
              GestureDetector(
                onTap: isIdle ? _showHobbySelector : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: hobbyState.selectedHobby != null
                              ? AppColors.timerRunning
                              : AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        hobbyState.selectedHobby?.name ?? '취미 선택',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: hobbyState.selectedHobby != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isIdle) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.unfold_more,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Timer display
              Column(
                children: [
                  // Status indicator
                  if (!isIdle)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isRunning
                            ? AppColors.timerRunning.withValues(alpha: 0.15)
                            : AppColors.timerPaused.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isRunning
                                  ? AppColors.timerRunning
                                  : AppColors.timerPaused,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isRunning ? '진행 중' : '일시정지',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isRunning
                                  ? AppColors.timerRunning
                                  : AppColors.timerPaused,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Time display
                  Text(
                    DurationFormatter.formatSeconds(timerState.elapsedSeconds),
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w200,
                      color: AppColors.textPrimary,
                      letterSpacing: 4,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Duration in readable format
                  Text(
                    DurationFormatter.formatHumanReadable(
                      Duration(seconds: timerState.elapsedSeconds),
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isIdle) ...[
                    // Stop button
                    _ControlButton(
                      icon: Icons.stop_rounded,
                      onTap: timerState.isLoading ? null : _stopTimer,
                      backgroundColor: AppColors.surface,
                      iconColor: AppColors.error,
                      size: 56,
                    ),
                    const SizedBox(width: 24),
                  ],

                  // Main button (Start/Pause/Resume)
                  _ControlButton(
                    icon: isIdle
                        ? Icons.play_arrow_rounded
                        : (isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    onTap: timerState.isLoading
                        ? null
                        : (isIdle
                            ? _startTimer
                            : (isRunning
                                ? () => ref.read(timerProvider.notifier).pauseTimer()
                                : () => ref.read(timerProvider.notifier).resumeTimer())),
                    backgroundColor: AppColors.textPrimary,
                    iconColor: AppColors.background,
                    size: 80,
                    enabled: hobbyState.selectedHobby != null || !isIdle,
                  ),
                ],
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final bool enabled;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.size,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.45,
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '취미 선택',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          ...hobbies.map((hobby) => _HobbyTile(
                hobby: hobby,
                isSelected: selectedHobby?.id == hobby.id,
                onTap: () => onSelect(hobby),
              )),
          const SizedBox(height: 8),
          _AddHobbyTile(onTap: onAddNew),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _HobbyTile extends StatelessWidget {
  final HobbyResponse hobby;
  final bool isSelected;
  final VoidCallback onTap;

  const _HobbyTile({
    required this.hobby,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceVariant : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.textTertiary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.timerRunning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                hobby.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.textPrimary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _AddHobbyTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddHobbyTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add,
              color: AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              '새 취미 추가',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
