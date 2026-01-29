import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class RecordState {
  final bool isLoading;
  final String? error;
  final RecordResponse? lastCreatedRecord;

  const RecordState({
    this.isLoading = false,
    this.error,
    this.lastCreatedRecord,
  });

  RecordState copyWith({
    bool? isLoading,
    String? error,
    RecordResponse? lastCreatedRecord,
    bool clearLastRecord = false,
  }) {
    return RecordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastCreatedRecord:
          clearLastRecord ? null : (lastCreatedRecord ?? this.lastCreatedRecord),
    );
  }
}

class RecordNotifier extends StateNotifier<RecordState> {
  final RecordRepository _recordRepository;

  RecordNotifier(this._recordRepository) : super(const RecordState());

  Future<RecordResponse?> createRecord(CreateRecordRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final record = await _recordRepository.createRecord(request);
      state = state.copyWith(
        isLoading: false,
        lastCreatedRecord: record,
      );
      return record;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return null;
    }
  }

  void clearLastRecord() {
    state = state.copyWith(clearLastRecord: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final recordProvider = StateNotifierProvider<RecordNotifier, RecordState>((ref) {
  return RecordNotifier(ref.read(recordRepositoryProvider));
});
