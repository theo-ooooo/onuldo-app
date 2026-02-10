import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/image_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

@RoutePage()
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  XFile? _selectedImage;
  String? _currentProfileImageUrl;
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final myInfoAsync = ref.read(myInfoProvider);
    myInfoAsync.whenData((user) {
      _nicknameController.text = user.nickname;
      _bioController.text = user.bio ?? '';
      _currentProfileImageUrl = user.profileImageUrl;
      setState(() {});
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedImage == null) return null;

    try {
      setState(() => _isUploading = true);

      final imageRepository = ref.read(imageRepositoryProvider);
      final file = File(_selectedImage!.path);
      final fileName = _selectedImage!.name;

      // 프로필 이미지 Presigned URL 발급 (contentType은 서버가 결정)
      final presigned = await imageRepository.getProfileImagePresignedUrl(
        fileName,
        null,
      );

      // 이미지 크기 가져오기 (업로드 전에)
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final width = frame.image.width;
      final height = frame.image.height;
      frame.image.dispose();

      // S3 업로드 — imageKey 확장자 기반 content-type 사용 (서버 서명과 일치시키기 위함)
      final s3ContentType = _getContentType(presigned.imageKey);
      await imageRepository.uploadToS3(
        presigned.uploadUrl,
        file,
        s3ContentType,
      );

      // 업로드 확인
      final imageResponse = await imageRepository.confirmProfileImageUpload(
        ConfirmImageUploadRequest(
          imageKey: presigned.imageKey,
          fileName: fileName,
          fileSize: bytes.length,
          width: width,
          height: height,
        ),
      );

      return imageResponse.profileImageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ApiException.extractMessage(e),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: context.colors.error,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userRepository = ref.read(userRepositoryProvider);
      
      // 프로필 이미지 업로드
      String? profileImageUrl;
      if (_selectedImage != null) {
        profileImageUrl = await _uploadProfileImage();
        if (profileImageUrl == null && _selectedImage != null) {
          // 이미지 업로드 실패 시 저장 중단
          setState(() => _isLoading = false);
          return;
        }
      }

      // 프로필 업데이트
      await userRepository.updateMyProfile(
        nickname: _nicknameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        profileImageUrl: profileImageUrl,
      );

      // 프로필 정보 새로고침
      ref.invalidate(myInfoProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 업데이트되었습니다'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ApiException.extractMessage(e),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '프로필 편집',
          style: typography.title3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isLoading || _isUploading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingIndicator(size: 20),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                '저장',
                style: typography.subhead.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // 프로필 이미지
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: colors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _currentProfileImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: CachedNetworkImage(
                                      imageUrl: _currentProfileImageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: Text(
                                          _nicknameController.text.isNotEmpty
                                              ? _nicknameController.text[0].toUpperCase()
                                              : 'U',
                                          style: typography.title1.copyWith(
                                            fontWeight: FontWeight.w300,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Center(
                                        child: Text(
                                          _nicknameController.text.isNotEmpty
                                              ? _nicknameController.text[0].toUpperCase()
                                              : 'U',
                                          style: typography.title1.copyWith(
                                            fontWeight: FontWeight.w300,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      _nicknameController.text.isNotEmpty
                                          ? _nicknameController.text[0].toUpperCase()
                                          : 'U',
                                      style: typography.title1.copyWith(
                                        fontWeight: FontWeight.w300,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colors.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.background,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: colors.background,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '프로필 사진 변경',
                  style: typography.footnote.copyWith(
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // 닉네임
                TextFormField(
                  controller: _nicknameController,
                  style: typography.body,
                  decoration: InputDecoration(
                    labelText: '닉네임',
                    hintText: '닉네임을 입력하세요',
                    hintStyle: typography.body.copyWith(
                      color: colors.textTertiary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.separatorOpaque),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.separatorOpaque),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.textPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: colors.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    if (value.trim().length < 2) {
                      return '닉네임은 2자 이상이어야 합니다';
                    }
                    if (value.trim().length > 50) {
                      return '닉네임은 50자 이하여야 합니다';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 소개
                TextFormField(
                  controller: _bioController,
                  style: typography.body,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: '소개',
                    hintText: '자기소개를 입력하세요',
                    hintStyle: typography.body.copyWith(
                      color: colors.textTertiary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.separatorOpaque),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.separatorOpaque),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.textPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: colors.surface,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

