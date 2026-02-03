import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';

@RoutePage()
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
      backgroundColor: Colors.transparent,
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
    final colors = context.colors;
    final typography = context.typography;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '새 취미 추가',
          style: typography.title3,
        ),
        content: TextField(
          controller: nameController,
          style: typography.body,
          decoration: InputDecoration(
            hintText: '취미 이름을 입력하세요',
            hintStyle: typography.body.copyWith(
              color: colors.textTertiary,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: colors.textSecondary),
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
                color: colors.textPrimary,
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
      context.router.push(
        CreateRecordRoute(
          timerId: result.id,
          hobbyId: result.hobbyId,
          hobbyName: selectedHobby?.name,
          durationSeconds: result.durationSeconds,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hobbyState = ref.watch(hobbyProvider);
    final timerState = ref.watch(timerProvider);
    final colors = context.colors;
    final typography = context.typography;

    final isRunning = timerState.status == LocalTimerStatus.running;
    final isIdle = timerState.status == LocalTimerStatus.idle;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogoIcon(size: 32),
                  const SizedBox(width: 8),
                  Text(
                    '오늘도',
                    style: typography.title3.copyWith(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Hobby selector
              GestureDetector(
                onTap: isIdle ? _showHobbySelector : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: hobbyState.selectedHobby != null
                              ? colors.timerRunning
                              : colors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        hobbyState.selectedHobby?.name ?? '취미 선택',
                        style: typography.body.copyWith(
                          color: hobbyState.selectedHobby != null
                              ? colors.textPrimary
                              : colors.textTertiary,
                        ),
                      ),
                      if (isIdle) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.unfold_more,
                          color: colors.textTertiary,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Status indicator
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: !isIdle
                    ? Container(
                        key: ValueKey(isRunning),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (isRunning ? colors.timerRunning : colors.timerPaused)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isRunning
                                    ? colors.timerRunning
                                    : colors.timerPaused,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isRunning ? '진행 중' : '일시정지',
                              style: typography.footnote.copyWith(
                                color: isRunning
                                    ? colors.timerRunning
                                    : colors.timerPaused,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(height: 28),
              ),

              const SizedBox(height: 24),

              // Time display
              Text(
                DurationFormatter.formatSeconds(timerState.elapsedSeconds),
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w100,
                  color: colors.textPrimary,
                  letterSpacing: 4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),

              const SizedBox(height: 8),

              // Human readable duration
              Text(
                DurationFormatter.formatHumanReadable(
                  Duration(seconds: timerState.elapsedSeconds),
                ),
                style: typography.body.copyWith(
                  color: colors.textTertiary,
                ),
              ),

              const Spacer(),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stop button (only when not idle)
                  if (!isIdle) ...[
                    _ControlButton(
                      icon: Icons.stop_rounded,
                      onTap: timerState.isLoading ? null : _stopTimer,
                      backgroundColor: colors.surface,
                      iconColor: colors.error,
                      size: 56,
                    ),
                    const SizedBox(width: 24),
                  ],

                  // Main button (Start/Pause/Resume)
                  _ControlButton(
                    icon: isIdle
                        ? Icons.play_arrow_rounded
                        : (isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                    onTap: timerState.isLoading
                        ? null
                        : (isIdle
                            ? _startTimer
                            : (isRunning
                                ? () => ref.read(timerProvider.notifier).pauseTimer()
                                : () => ref.read(timerProvider.notifier).resumeTimer())),
                    backgroundColor: colors.textPrimary,
                    iconColor: colors.background,
                    size: 80,
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
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.separator,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '취미 선택',
                style: typography.title3,
              ),
              const SizedBox(height: 16),

              // Hobby list
              ...hobbies.map((hobby) => _HobbyTile(
                    hobby: hobby,
                    isSelected: selectedHobby?.id == hobby.id,
                    onTap: () => onSelect(hobby),
                  )),

              const SizedBox(height: 8),

              // Add new hobby
              GestureDetector(
                onTap: onAddNew,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.separatorOpaque,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: colors.textTertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '새 취미 추가',
                        style: typography.body.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.textTertiary : colors.separatorOpaque,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.timerRunning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                hobby.name,
                style: typography.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: colors.textPrimary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
