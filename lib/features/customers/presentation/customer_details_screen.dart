import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../conversations/presentation/conversation_list_controller.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  const CustomerDetailsScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(conversationsStreamProvider);
    return cases.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text('Customer not found'))),
      data: (conversations) {
        final matching = conversations
            .where((item) => item.customer.id == customerId)
            .toList();
        if (matching.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Customer not found')),
          );
        }
        final currentCustomer = matching.first.customer;
        return Scaffold(
          appBar: AppBar(title: const Text('Customer details')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CustomerAvatar(
                  name: currentCustomer.displayName,
                  size: 64,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  currentCustomer.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 24),
              _InfoCard(title: 'Phone', value: currentCustomer.phone),
              _InfoCard(title: 'Email', value: currentCustomer.email),
              _InfoCard(title: 'Language', value: currentCustomer.language),
              _InfoCard(title: 'Customer ID', value: currentCustomer.id),
              _InfoCard(
                title: 'Website session ID',
                value: currentCustomer.websiteSessionId,
              ),
              const SizedBox(height: 8),
              Text(
                'Booking & history',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...matching.map(
                (conversation) => Card(
                  child: ListTile(
                    title: Text(conversation.bookingSummary.bookingReference),
                    subtitle: Text(
                      '${conversation.bookingSummary.vehicleName} • ${conversation.latestMessage}',
                    ),
                    trailing: Text(conversation.status.name),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
        ),
        subtitle: Text(value),
      ),
    );
  }
}
