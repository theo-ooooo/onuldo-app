import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class RecordState {
  final bool isLoading;
  final String? error;
  final RecordResponse? lastCreatedRecord;
  final List<XFile> selectedImages;
  final bool isUploading;
  final double uploadProgress;

  const RecordState({
    this.isLoading = false,
    this.error,
    this.lastCreatedRecord,
    this.selectedImages = const [],
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  RecordState copyWith({
    bool? isLoading,
    String? error,
    RecordResponse? lastCreatedRecord,
    bool clearLastRecord = false,
    List<XFile>? selectedImages,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return RecordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastCreatedRecord:
          clearLastRecord ? null : (lastCreatedRecord ?? this.lastCreatedRecord),
      selectedImages: selectedImages ?? this.selectedImages,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class RecordNotifier extends StateNotifier<RecordState> {
  final RecordRepository _recordRepository;
  final ImageRepository _imageRepository;

  RecordNotifier(this._recordRepository, this._imageRepository)
      : super(const RecordState());

  void addImages(List<XFile> images) {
    state = state.copyWith(
      selectedImages: [...state.selectedImages, ...images],
    );
  }

  void removeImage(int index) {
    final images = [...state.selectedImages];
    images.removeAt(index);
    state = state.copyWith(selectedImages: images);
  }

  void clearImages() {
    state = state.copyWith(selectedImages: const []);
  }

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

  Future<RecordResponse?> createRecordWithImages(
    CreateRecordRequest request,
  ) async {
    state = state.copyWith(isLoading: true, isUploading: false, error: null);

    try {
      // 1. 기록 생성
      final record = await _recordRepository.createRecord(request);

      // 2. 이미지 업로드
      if (state.selectedImages.isNotEmpty) {
        state = state.copyWith(isUploading: true, uploadProgress: 0.0);

        final totalImages = state.selectedImages.length;
        for (var i = 0; i < totalImages; i++) {
          final xFile = state.selectedImages[i];
          final file = File(xFile.path);
          final fileName = xFile.name;

          // Presigned URL 발급 (contentType은 서버가 결정)
          final presigned = await _imageRepository.getPresignedUrl(
            record.id,
            fileName,
            null,
          );

          // S3 업로드 — imageKey 확장자 기반 content-type 사용 (서버 서명과 일치시키기 위함)
          final s3ContentType = _getContentType(presigned.imageKey);
          await _imageRepository.uploadToS3(
            presigned.uploadUrl,
            file,
            s3ContentType,
          );

          // 이미지 크기 가져오기
          final bytes = await file.readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          final width = frame.image.width;
          final height = frame.image.height;
          frame.image.dispose();

          // 업로드 확인
          await _imageRepository.confirmImageUpload(
            record.id,
            ConfirmImageUploadRequest(
              imageKey: presigned.imageKey,
              fileName: fileName,
              fileSize: bytes.length,
              width: width,
              height: height,
            ),
          );

          state = state.copyWith(
            uploadProgress: (i + 1) / totalImages,
          );
        }
      }

      state = state.copyWith(
        isLoading: false,
        isUploading: false,
        lastCreatedRecord: record,
        selectedImages: const [],
        uploadProgress: 0.0,
      );
      return record;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isUploading: false,
        error: e.message,
        uploadProgress: 0.0,
      );
      return null;
    }
  }

  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
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
  return RecordNotifier(
    ref.read(recordRepositoryProvider),
    ref.read(imageRepositoryProvider),
  );
});
