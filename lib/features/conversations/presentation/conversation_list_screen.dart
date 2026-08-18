import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/screen_header_shell.dart';
import '../../../shared/models/support_models.dart';
import '../../inbox/presentation/widgets/conversation_tile.dart';
import 'conversation_list_controller.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key, this.initialStatus});

  final String? initialStatus;

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref
          .read(conversationListControllerProvider.notifier)
          .updateStatus(_statusFromQuery(widget.initialStatus));
    });
  }

  @override
  void didUpdateWidget(covariant ConversationListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      final status = _statusFromQuery(widget.initialStatus);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(conversationListControllerProvider.notifier)
              .updateStatus(status);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationListControllerProvider);
    final controller = ref.read(conversationListControllerProvider.notifier);
    final conversations = ref.watch(conversationsStreamProvider);

    final selectedIndex = _statusToIndex(state.selectedStatus);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: ScreenHeaderShell(
        title: 'Conversations',
        subtitle: 'Search and manage support threads',
        leadingIcon: Icons.chat_bubble_outline_rounded,
        child: conversations.when(
          loading: () =>
              const AppLoadingView(label: 'Loading conversations...'),
          error: (error, stackTrace) => _ConversationLoadError(
            onRetry: () => ref.invalidate(conversationsStreamProvider),
          ),
          data: (allConversations) {
            final visibleConversations = controller.filterConversations(
              allConversations,
            );

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search conversations',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onChanged: controller.updateQuery,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(4, (index) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index == 3 ? 0 : 6,
                              ),
                              child: _ConversationFilterTab(
                                label: _statusLabel(index),
                                selected: selectedIndex == index,
                                onTap: () => controller.updateStatus(
                                  _statusFromIndex(index),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshConversations,
                    child: visibleConversations.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 110),
                              EmptyStateView(
                                title: 'No conversations found',
                                message:
                                    'Try changing the filter or search query.',
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                            itemCount: visibleConversations.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 12);
                            },
                            itemBuilder: (context, index) {
                              final conversation = visibleConversations[index];

                              return ConversationTile(
                                conversation: conversation,
                                onTap: () {
                                  debugPrint(
                                    '[Chat navigation] tapped conversationId='
                                    '${conversation.id}',
                                  );
                                  context.push(
                                    AppRoutes.chatPath(conversation.id),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ConversationStatus? _statusFromQuery(String? query) {
    switch (query) {
      case 'assigned':
        return ConversationStatus.assigned;

      case 'waiting':
        return ConversationStatus.waitingForRepresentative;

      case 'resolved':
        return ConversationStatus.resolved;

      case 'new':
      case 'newRequest':
      default:
        return ConversationStatus.newRequest;
    }
  }

  int _statusToIndex(ConversationStatus? status) {
    switch (status) {
      case ConversationStatus.assigned:
      case ConversationStatus.representativeReplied:
        return 1;

      case ConversationStatus.waitingForRepresentative:
      case ConversationStatus.waitingForCustomer:
        return 2;

      case ConversationStatus.resolved:
      case ConversationStatus.closed:
        return 3;

      case null:
      case ConversationStatus.newRequest:
      case ConversationStatus.unassigned:
      case ConversationStatus.botActive:
      case ConversationStatus.reopened:
        return 0;
    }
  }

  ConversationStatus _statusFromIndex(int index) {
    switch (index) {
      case 1:
        return ConversationStatus.assigned;

      case 2:
        return ConversationStatus.waitingForRepresentative;

      case 3:
        return ConversationStatus.resolved;

      default:
        return ConversationStatus.newRequest;
    }
  }

  String _statusLabel(int index) {
    switch (index) {
      case 1:
        return 'Assigned';

      case 2:
        return 'Waiting';

      case 3:
        return 'Resolved';

      default:
        return 'New';
    }
  }

  Future<void> _refreshConversations() async {
    ref.invalidate(conversationsStreamProvider);
    await ref.read(conversationsStreamProvider.future);
  }
}

class _ConversationFilterTab extends StatelessWidget {
  const _ConversationFilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.secondaryText;
    return Material(
      color: selected ? AppColors.primaryDarkBlue : AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primaryDarkBlue : AppColors.border,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationLoadError extends StatelessWidget {
  const _ConversationLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Couldn't load conversations. Please try again.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
