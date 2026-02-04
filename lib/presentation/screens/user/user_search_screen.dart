import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../router/app_router.dart';

@RoutePage()
class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(userSearchProvider.notifier).searchUsers(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(userSearchProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const PageHeader(
              title: '검색',
            ),

            const SizedBox(height: 16),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: typography.body,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: '닉네임 또는 이메일로 검색',
                    hintStyle: typography.body.copyWith(
                      color: colors.textTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colors.textTertiary,
                    ),
                    suffixIcon: searchState.query.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: colors.textTertiary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(userSearchProvider.notifier).clearSearch();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _buildBody(searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(UserSearchState state) {
    final colors = context.colors;
    final typography = context.typography;

    if (state.query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.person_search_outlined,
                size: 36,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '사용자를 검색해보세요',
              style: typography.subhead.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return const Center(child: LoadingIndicator(size: 48));
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => _onSearch(state.query),
      );
    }

    if (state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off_outlined,
                size: 36,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '검색 결과가 없습니다',
              style: typography.subhead.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: state.users.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: colors.separatorOpaque,
        indent: 68,
      ),
      itemBuilder: (context, index) {
        final user = state.users[index];
        return _UserTile(
          user: user,
          onTap: () {
            context.router.push(UserProfileRoute(userId: user.userId));
          },
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final dynamic user;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                image: user.profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user.profileImageUrl == null
                  ? Center(
                      child: Text(
                        user.nickname[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname,
                    style: typography.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: typography.footnote.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
