import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/screen_header_shell.dart';
import '../../../shared/models/support_models.dart';
import 'widgets/conversation_tile.dart';
import 'widgets/summary_card.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inboxControllerProvider);
    final controller = ref.read(inboxControllerProvider.notifier);
    final representative = ref.watch(currentRepresentativeProvider);

    if (state.isLoading) {
      return const Scaffold(body: AppLoadingView(label: 'Loading inbox...'));
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: ScreenHeaderShell(
        title: 'Inbox',
        subtitle: '',
        leadingIcon: Icons.inbox_outlined,
        trailing: HeaderActionButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          showBadge: true,
          onPressed: () => context.go(AppRoutes.notifications),
        ),
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primaryDarkBlue,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              if (state.isOffline) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paleRed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryRed),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: AppColors.primaryRed,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Unable to reach the support server. Pull down to retry.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.mainText),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                '${_greeting()}, ${_firstName(representative.name)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryDarkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Customer support overview',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                  final items = <_SummaryItem>[
                    _SummaryItem(
                      title: 'New Inquiries',
                      value: '${state.summary.newRequests}',
                      icon: Icons.mark_chat_unread_outlined,
                      onTap: () => _openConversations(
                        context,
                        ref,
                        ConversationStatus.newRequest,
                        'new',
                      ),
                    ),
                    _SummaryItem(
                      title: AppStrings.assignedToMe,
                      value: '${state.summary.assignedToMe}',
                      icon: Icons.assignment_ind_outlined,
                      onTap: () => _openConversations(
                        context,
                        ref,
                        ConversationStatus.assigned,
                        'assigned',
                      ),
                    ),
                    _SummaryItem(
                      title: AppStrings.waiting,
                      value: '${state.summary.waiting}',
                      icon: Icons.hourglass_bottom_outlined,
                      onTap: () => _openConversations(
                        context,
                        ref,
                        ConversationStatus.waitingForRepresentative,
                        'waiting',
                      ),
                    ),
                    _SummaryItem(
                      title: AppStrings.resolvedToday,
                      value: '${state.summary.resolvedToday}',
                      icon: Icons.task_alt_outlined,
                      onTap: () => _openConversations(
                        context,
                        ref,
                        ConversationStatus.resolved,
                        'resolved',
                      ),
                    ),
                  ];

                  return GridView.builder(
                    itemCount: items.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 118,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return SummaryCard(
                        title: item.title,
                        value: item.value,
                        icon: item.icon,
                        onTap: item.onTap,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent conversations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openConversations(
                      context,
                      ref,
                      ConversationStatus.resolved,
                      'resolved',
                    ),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (state.recentConversations.isEmpty)
                const SizedBox(
                  height: 220,
                  child: EmptyStateView(
                    title: 'No completed conversations yet',
                    message:
                        'Resolved customer conversations will appear here.',
                  ),
                )
              else
                ...state.recentConversations.map(
                  (conversation) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ConversationTile(
                      conversation: conversation,
                      onTap: () =>
                          context.push(AppRoutes.chatPath(conversation.id)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _firstName(String fullName) {
    final value = fullName.trim();
    return value.isEmpty ? 'Representative' : value.split(RegExp(r'\s+')).first;
  }

  void _openConversations(
    BuildContext context,
    WidgetRef ref,
    ConversationStatus status,
    String statusQuery,
  ) {
    ref.read(conversationListControllerProvider.notifier).updateStatus(status);
    context.go('${AppRoutes.conversations}?status=$statusQuery');
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
}
