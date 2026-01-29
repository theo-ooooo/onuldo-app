import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hobbyProvider.notifier).loadHobbies();
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('로그아웃'),
          ),
        ],
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

  void _showEditHobbyDialog(HobbyResponse hobby) {
    final nameController = TextEditingController(text: hobby.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('취미 수정'),
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
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _showDeleteHobbyDialog(hobby);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final success = await ref.read(hobbyProvider.notifier).updateHobby(
                    hobby.id,
                    UpdateHobbyRequest(name: nameController.text.trim()),
                  );

              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showDeleteHobbyDialog(HobbyResponse hobby) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('취미 삭제'),
        content: Text('${hobby.name}을(를) 삭제하시겠습니까?\n관련된 기록은 삭제되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(hobbyProvider.notifier).deleteHobby(hobby.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final hobbyState = ref.watch(hobbyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        authState.user?.nickname[0].toUpperCase() ?? 'U',
                        style: AppTextStyles.h1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.user?.nickname ?? '사용자',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authState.user?.email ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Hobbies section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('내 취미', style: AppTextStyles.h4),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddHobbyDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (hobbyState.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: LoadingIndicator(),
              )
            else if (hobbyState.hobbies.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '아직 등록된 취미가 없습니다',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddHobbyDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('취미 추가하기'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: hobbyState.hobbies.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final hobby = hobbyState.hobbies[index];
                    return ListTile(
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
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showEditHobbyDialog(hobby),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
