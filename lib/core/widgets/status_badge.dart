import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../../shared/models/support_models.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  factory StatusBadge.conversation(ConversationStatus status) {
    switch (status) {
      case ConversationStatus.newRequest:
        return const StatusBadge(
          label: 'New',
          backgroundColor: AppColors.paleBlue,
          foregroundColor: AppColors.primaryDarkBlue,
        );
      case ConversationStatus.assigned:
        return const StatusBadge(
          label: 'Assigned',
          backgroundColor: AppColors.paleBlue,
          foregroundColor: AppColors.primaryDarkBlue,
        );
      case ConversationStatus.waitingForRepresentative:
      case ConversationStatus.waitingForCustomer:
        return const StatusBadge(
          label: 'Waiting',
          backgroundColor: AppColors.warningAmber,
          foregroundColor: AppColors.white,
        );
      case ConversationStatus.resolved:
        return const StatusBadge(
          label: 'Resolved',
          backgroundColor: AppColors.successGreen,
          foregroundColor: AppColors.white,
        );
      case ConversationStatus.reopened:
        return const StatusBadge(
          label: 'Reopened',
          backgroundColor: AppColors.paleRed,
          foregroundColor: AppColors.primaryRed,
        );
      case ConversationStatus.botActive:
      case ConversationStatus.unassigned:
      case ConversationStatus.representativeReplied:
      case ConversationStatus.closed:
        return const StatusBadge(
          label: 'Open',
          backgroundColor: AppColors.softGrey,
          foregroundColor: AppColors.mainText,
        );
    }
  }

  factory StatusBadge.delivery(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return const StatusBadge(
          label: 'Pending',
          backgroundColor: AppColors.softGrey,
          foregroundColor: AppColors.secondaryText,
        );
      case DeliveryStatus.sent:
        return const StatusBadge(
          label: 'Sent',
          backgroundColor: AppColors.paleBlue,
          foregroundColor: AppColors.primaryDarkBlue,
        );
      case DeliveryStatus.delivered:
        return const StatusBadge(
          label: 'Delivered',
          backgroundColor: AppColors.paleBlue,
          foregroundColor: AppColors.primaryDarkBlue,
        );
      case DeliveryStatus.read:
        return const StatusBadge(
          label: 'Read',
          backgroundColor: AppColors.successGreen,
          foregroundColor: AppColors.white,
        );
      case DeliveryStatus.failed:
        return const StatusBadge(
          label: 'Failed',
          backgroundColor: AppColors.paleRed,
          foregroundColor: AppColors.primaryRed,
        );
    }
  }

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
