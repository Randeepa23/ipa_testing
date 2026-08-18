import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../shared/models/support_models.dart';
import 'chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = chatControllerProvider(widget.conversationId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final caseDetail = ref.watch(chatCaseProvider(widget.conversationId));

    if (_messageController.text != state.messageText) {
      _messageController.value = TextEditingValue(
        text: state.messageText,
        selection: TextSelection.collapsed(offset: state.messageText.length),
      );
    }

    return caseDetail.when(
      loading: () => const Scaffold(
        body: AppLoadingView(label: 'Loading conversation...'),
      ),
      error: (error, stackTrace) => _ChatLoadFailureScreen(
        message: "Couldn't load this conversation.",
        onRetry: () async {
          ref.invalidate(chatCaseProvider(widget.conversationId));
        },
        onBack: () => _navigateBack(context),
      ),
      data: (detail) {
        final conversation = detail.conversation;
        final messages = detail.messages;
            final isResolved =
                conversation.status == ConversationStatus.resolved ||
                conversation.status == ConversationStatus.closed;

            final needsAcceptance =
                conversation.status == ConversationStatus.newRequest ||
                conversation.status == ConversationStatus.unassigned ||
                conversation.status == ConversationStatus.reopened;

            return Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: AppColors.lightBackground,
              appBar: AppBar(
                leading: IconButton(
                  tooltip: 'Back',
                  onPressed: () {
                    _navigateBack(context);
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                titleSpacing: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          conversation.isWebsiteInquiry
                              ? Icons.mail_outline_rounded
                              : Icons.chat_bubble_outline_rounded,
                          color: AppColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            conversation.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      conversation.displayEmail ??
                          '${conversation.bookingSummary.bookingReference}'
                              ' • '
                              '${conversation.bookingSummary.vehicleName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFC7DBFF),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'Customer details',
                    onPressed: () {
                      context.push('/customers/${conversation.customer.id}');
                    },
                    icon: const Icon(Icons.person_outline_rounded),
                  ),
                  IconButton(
                    tooltip: 'More actions',
                    onPressed: () {
                      _showActions(context, conversation, controller);
                    },
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),
              body: Column(
                children: [
                  _EscalationBanner(
                    reason: conversation.escalationReason,
                    triggerMessage: _findTriggerMessage(conversation, messages),
                  ),
                  if (needsAcceptance)
                    _AcceptBanner(
                      onAccept: () async {
                        await controller.acceptConversation();
                      },
                    ),
                  if (isResolved)
                    _ResolvedBanner(
                      onReopen: () async {
                        await controller.reopenConversation();
                      },
                    ),
                  if (state.errorMessage != null)
                    _ErrorBanner(
                      message: state.errorMessage!,
                      onClose: controller.clearError,
                    ),
                  Expanded(
                    child: messages.isEmpty
                        ? const Center(child: Text('No messages yet'))
                        : ListView.builder(
                            controller: _scrollController,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _MessageBubble(
                                  message: message,
                                  onRetry: null,
                                ),
                              );
                            },
                          ),
                  ),
                  if (!isResolved)
                    _MessageComposer(
                      controller: _messageController,
                      isSending: state.isSending,
                      onSend: () async {
                        await controller.sendMessage(_messageController.text);
                        _scrollToBottom();
                      },
                      onInternalNote: () async {
                        await controller.sendMessage(
                          _messageController.text,
                          internalNote: true,
                        );
                        _scrollToBottom();
                      },
                      onResolve: () async {
                        await _confirmResolve(context, controller);
                      },
                      onHoldOrResume:
                          conversation.status == ConversationStatus.assigned
                          ? () async {
                              final resumed = conversation.onHold;
                              final success = resumed
                                  ? await controller.resumeConversation()
                                  : await controller.holdConversation();
                              if (!context.mounted || !success) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    resumed
                                        ? 'Case resumed.'
                                        : 'Case put on hold.',
                                  ),
                                ),
                              );
                              if (!resumed) {
                                _navigateBack(context);
                              }
                            }
                          : null,
                      isOnHold: conversation.onHold,
                    ),
                ],
              ),
            );
      },
    );
  }

  void _navigateBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.conversations);
  }

  String _findTriggerMessage(
    Conversation conversation,
    List<ChatMessage> messages,
  ) {
    for (final message in messages) {
      if (message.id == conversation.triggerMessageId) {
        return message.content;
      }
    }

    return conversation.latestMessage;
  }

  Future<void> _confirmResolve(
    BuildContext context,
    ChatController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return const ConfirmationDialog(
          title: 'Resolve conversation?',
          message: 'The complete conversation history will remain available.',
          confirmLabel: 'Resolve',
          cancelLabel: 'Cancel',
        );
      },
    );

    if (confirmed == true) {
      await controller.resolveConversation();
    }
  }

  void _showActions(
    BuildContext context,
    Conversation conversation,
    ChatController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Customer details'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    context.push(
                      AppRoutes.customerDetailsPath(conversation.customer.id),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.swap_horiz_rounded),
                  title: const Text('Transfer conversation'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.task_alt_outlined),
                  title: const Text('Resolve conversation'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    _confirmResolve(context, controller);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}

class _ChatLoadFailureScreen extends StatelessWidget {
  const _ChatLoadFailureScreen({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final Future<void> Function() onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Conversation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}

class _EscalationBanner extends StatelessWidget {
  const _EscalationBanner({required this.reason, required this.triggerMessage});

  final String reason;
  final String triggerMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE6F9FD),
        border: Border(left: BorderSide(color: Color(0xFF00A6C7), width: 5)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF007D9A),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Escalated by chatbot',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF063D59),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            reason,
            textAlign: TextAlign.start,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF285C70),
              height: 1.35,
            ),
          ),
          if (triggerMessage.trim().isNotEmpty) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFCFF3FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF9FDFEC)),
              ),
              child: Text(
                '"$triggerMessage"',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF06445C),
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AcceptBanner extends StatelessWidget {
  const _AcceptBanner({required this.onAccept});

  final Future<void> Function() onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.paleBlue,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          const Expanded(child: Text('Accept this request before replying.')),
          const SizedBox(width: 10),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () async {
              await onAccept();
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}

class _ResolvedBanner extends StatelessWidget {
  const _ResolvedBanner({required this.onReopen});

  final Future<void> Function() onReopen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.paleBlue,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.task_alt_rounded, color: AppColors.successGreen),
          const SizedBox(width: 8),
          const Expanded(child: Text('This conversation has been resolved.')),
          TextButton(
            onPressed: () async {
              await onReopen();
            },
            child: const Text('Reopen'),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paleRed,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.primaryRed,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.primaryRed),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onRetry});

  final ChatMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (message.senderType == SenderType.system && !message.isInternalNote) {
      return _SystemMessage(message: message);
    }

    final isRepresentative = message.senderType == SenderType.representative;

    final isCustomer = message.senderType == SenderType.customer;

    final alignment = isRepresentative || isCustomer
        ? Alignment.centerRight
        : Alignment.centerLeft;

    final backgroundColor = message.isInternalNote
        ? AppColors.internalNote
        : isRepresentative
        ? AppColors.primaryDarkBlue
        : isCustomer
        ? AppColors.paleBlue
        : AppColors.chatbotGrey;

    final foregroundColor = isRepresentative
        ? AppColors.white
        : AppColors.mainText;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: isRepresentative || isCustomer
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.isInternalNote
                  ? 'Internal note'
                  : '${message.senderName} • '
                        '${DateFormat('h:mm a').format(message.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: message.isInternalNote
                    ? Border.all(color: AppColors.border)
                    : null,
              ),
              child: Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  height: 1.35,
                ),
              ),
            ),
            if (isRepresentative) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _deliveryLabel(message.deliveryStatus),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: message.deliveryStatus == DeliveryStatus.failed
                          ? AppColors.primaryRed
                          : AppColors.secondaryText,
                      fontSize: 9,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(width: 7),
                    GestureDetector(
                      onTap: onRetry,
                      child: Text(
                        'Retry',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _deliveryLabel(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Sending...';
      case DeliveryStatus.sent:
        return 'Sent';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.read:
        return 'Read';
      case DeliveryStatus.failed:
        return 'Failed';
    }
  }
}

class _SystemMessage extends StatelessWidget {
  const _SystemMessage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.softGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message.content,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onInternalNote,
    required this.onResolve,
    required this.onHoldOrResume,
    required this.isOnHold,
  });

  final TextEditingController controller;
  final bool isSending;
  final Future<void> Function() onSend;
  final Future<void> Function() onInternalNote;
  final Future<void> Function() onResolve;
  final Future<void> Function()? onHoldOrResume;
  final bool isOnHold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                TextButton.icon(
                  onPressed: !isSending
                      ? () async {
                          await onInternalNote();
                        }
                      : null,
                  icon: const Icon(Icons.note_add_outlined, size: 17),
                  label: const Text('Internal note'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onHoldOrResume == null
                      ? null
                      : () async {
                          await onHoldOrResume!();
                        },
                  icon: Icon(
                    isOnHold
                        ? Icons.play_circle_outline_rounded
                        : Icons.pause_circle_outline_rounded,
                    size: 17,
                  ),
                  label: Text(isOnHold ? 'Resume' : 'Hold'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    await onResolve();
                  },
                  icon: const Icon(Icons.task_alt_outlined, size: 17),
                  label: const Text('Resolve'),
                ),
              ],
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final hasText = value.text.trim().isNotEmpty;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type your reply...',
                          prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: hasText && !isSending ? onSend : null,
                        child: isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
