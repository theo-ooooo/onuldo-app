import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

enum LocalTimerStatus {
  idle,
  running,
  paused,
}

class TimerState {
  final LocalTimerStatus status;
  final TimerResponse? serverTimer;
  final TimerStopResult? stopResult;
  final int elapsedSeconds;
  final bool isLoading;
  final String? error;

  const TimerState({
    this.status = LocalTimerStatus.idle,
    this.serverTimer,
    this.stopResult,
    this.elapsedSeconds = 0,
    this.isLoading = false,
    this.error,
  });

  TimerState copyWith({
    LocalTimerStatus? status,
    TimerResponse? serverTimer,
    TimerStopResult? stopResult,
    int? elapsedSeconds,
    bool? isLoading,
    String? error,
    bool clearStopResult = false,
    bool clearServerTimer = false,
  }) {
    return TimerState(
      status: status ?? this.status,
      serverTimer: clearServerTimer ? null : (serverTimer ?? this.serverTimer),
      stopResult: clearStopResult ? null : (stopResult ?? this.stopResult),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  final TimerRepository _timerRepository;
  Timer? _localTimer;

  TimerNotifier(this._timerRepository) : super(const TimerState());

  Future<void> loadCurrentTimer() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final timer = await _timerRepository.getCurrentTimer();
      if (timer != null) {
        state = state.copyWith(
          serverTimer: timer,
          elapsedSeconds: timer.durationSeconds,
          status: timer.status == TimerStatus.running
              ? LocalTimerStatus.running
              : timer.status == TimerStatus.paused
                  ? LocalTimerStatus.paused
                  : LocalTimerStatus.idle,
          isLoading: false,
        );

        if (timer.status == TimerStatus.running) {
          _startLocalTimer();
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          status: LocalTimerStatus.idle,
        );
      }
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  Future<bool> startTimer(int hobbyId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final timer = await _timerRepository.startTimer(
        StartTimerRequest(hobbyId: hobbyId),
      );

      state = state.copyWith(
        serverTimer: timer,
        status: LocalTimerStatus.running,
        elapsedSeconds: timer.durationSeconds,
        isLoading: false,
      );

      _startLocalTimer();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  Future<bool> pauseTimer() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final timer = await _timerRepository.pauseTimer();
      _stopLocalTimer();

      state = state.copyWith(
        serverTimer: timer,
        status: LocalTimerStatus.paused,
        elapsedSeconds: timer.durationSeconds,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  Future<bool> resumeTimer() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final timer = await _timerRepository.resumeTimer();

      state = state.copyWith(
        serverTimer: timer,
        status: LocalTimerStatus.running,
        elapsedSeconds: timer.durationSeconds,
        isLoading: false,
      );

      _startLocalTimer();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  Future<TimerStopResult?> stopTimer() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _timerRepository.stopTimer();
      _stopLocalTimer();

      state = state.copyWith(
        stopResult: result,
        status: LocalTimerStatus.idle,
        elapsedSeconds: 0,
        isLoading: false,
        clearServerTimer: true,
      );
      return result;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return null;
    }
  }

  void _startLocalTimer() {
    _stopLocalTimer();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsedSeconds: state.elapsedSeconds + 1,
      );
    });
  }

  void _stopLocalTimer() {
    _localTimer?.cancel();
    _localTimer = null;
  }

  void clearStopResult() {
    state = state.copyWith(clearStopResult: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _stopLocalTimer();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref.read(timerRepositoryProvider));
});
