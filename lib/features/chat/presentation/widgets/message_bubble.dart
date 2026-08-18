import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/models/support_models.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.onRetry});

  final ChatMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.senderType == SenderType.customer;
    final isRepresentative = message.senderType == SenderType.representative;
    final isInternal = message.isInternalNote;
    final isSystem = message.senderType == SenderType.system;

    final backgroundColor = isRepresentative
        ? AppColors.primaryDarkBlue
        : isCustomer
        ? AppColors.paleBlue
        : isInternal
        ? AppColors.internalNote
        : isSystem
        ? AppColors.softGrey
        : AppColors.chatbotGrey;
    final textColor = isRepresentative ? AppColors.white : AppColors.mainText;
    final alignRight = isCustomer || isRepresentative;

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isInternal ? 'Internal note' : message.senderName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isRepresentative
                  ? AppColors.white
                  : AppColors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message.content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textColor),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('h:mm a').format(message.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isRepresentative
                      ? AppColors.white
                      : AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.delivery(message.deliveryStatus),
              if (message.deliveryStatus == DeliveryStatus.failed &&
                  onRetry != null) ...[
                const SizedBox(width: 8),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ],
      ),
    );

    if (isSystem) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: bubble,
        ),
      );
    }

    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: bubble,
      ),
    );
  }
}
