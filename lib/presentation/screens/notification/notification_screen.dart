import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

@RoutePage()
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.router.maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '알림',
                      style: typography.title2,
                    ),
                  ),
                  TextButton(
                    onPressed: state.notifications.isEmpty
                        ? null
                        : () => ref.read(notificationProvider.notifier).markAllAsRead(),
                    child: Text(
                      '전체 읽음',
                      style: typography.footnote.copyWith(
                        color: state.notifications.isEmpty
                            ? colors.textTertiary
                            : colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.isLoading
                  ? const Center(child: LoadingIndicator(size: 48))
                  : state.error != null
                      ? ErrorView(
                          message: state.error!,
                          onRetry: () => ref
                              .read(notificationProvider.notifier)
                              .loadNotifications(),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(notificationProvider.notifier)
                              .loadNotifications(),
                          child: state.notifications.isEmpty
                              ? ListView(
                                  children: [
                                    const SizedBox(height: 120),
                                    Center(
                                      child: Text(
                                        '새 알림이 없습니다',
                                        style: typography.body.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                                  itemCount: state.notifications.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final n = state.notifications[index];
                                    return _NotificationTile(
                                      title: n.title,
                                      content: n.content,
                                      createdAt: n.createdAt,
                                      isRead: n.isRead,
                                      onTap: () => ref
                                          .read(notificationProvider.notifier)
                                          .markAsRead(n),
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? colors.surface : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead ? colors.separatorOpaque : colors.textPrimary.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: isRead ? Colors.transparent : colors.timerRunning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.headline.copyWith(
                      color: colors.textPrimary,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: typography.subhead.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatTime(createdAt),
                    style: typography.caption2.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}


