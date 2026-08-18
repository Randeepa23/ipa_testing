import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/routing/app_routes.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/screen_header_shell.dart';
import '../../../shared/models/support_models.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: ScreenHeaderShell(
        title: 'Notifications',
        subtitle: 'Support requests and customer updates',
        leadingIcon: Icons.notifications_none_rounded,
        trailing: HeaderActionButton(
          icon: Icons.done_all_rounded,
          tooltip: 'Mark all as read',
          onPressed: controller.markAllRead,
        ),
        child: state.isLoading
            ? const AppLoadingView(label: 'Loading notifications...')
            : state.items.isEmpty
            ? const EmptyStateView(
                title: 'No notifications',
                message: 'New support notifications will appear here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                itemCount: state.items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];

                  return Card(
                    color: item.isRead ? AppColors.white : AppColors.paleBlue,
                    // ListTile paints its selection and ink effects on its
                    // closest Material ancestor. Supplying one here keeps
                    // them visible above Card's colored background.
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        onTap: item.conversationId == null
                            ? null
                            : () {
                                context.push(
                                  AppRoutes.chatPath(item.conversationId!),
                                );
                              },
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _iconForType(item.type),
                            color: AppColors.primaryDarkBlue,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            '${item.body}\n'
                            '${DateFormat('MMM d, h:mm a').format(item.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.secondaryText),
                          ),
                        ),
                        isThreeLine: true,
                        trailing: item.isRead
                            ? const SizedBox.shrink()
                            : const Icon(
                                Icons.circle,
                                size: 10,
                                color: AppColors.primaryRed,
                              ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.newSupportRequest:
        return Icons.mark_chat_unread_outlined;
      case NotificationType.customerReplied:
        return Icons.reply_outlined;
      case NotificationType.conversationAssigned:
        return Icons.assignment_ind_outlined;
      case NotificationType.conversationTransferred:
        return Icons.swap_horiz_rounded;
      case NotificationType.representativeMentioned:
        return Icons.alternate_email_rounded;
      case NotificationType.conversationResolved:
        return Icons.task_alt_outlined;
      case NotificationType.conversationReopened:
        return Icons.refresh_rounded;
      case NotificationType.waitingTimeWarning:
        return Icons.warning_amber_outlined;
    }
  }
}
