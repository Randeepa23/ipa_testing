import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class EscalationBanner extends StatelessWidget {
  const EscalationBanner({
    super.key,
    required this.reason,
    required this.triggerMessage,
  });

  final String reason;
  final String triggerMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paleRed,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.priority_high,
                color: AppColors.primaryRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Escalated by chatbot',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.mainText),
          ),
          const SizedBox(height: 8),
          Text(
            triggerMessage,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
