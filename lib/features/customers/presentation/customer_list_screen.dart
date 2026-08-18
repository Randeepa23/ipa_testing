import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../core/widgets/screen_header_shell.dart';
import '../../conversations/presentation/conversation_list_controller.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(conversationsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: ScreenHeaderShell(
        title: 'Customers',
        subtitle: 'Guest and booking profiles',
        leadingIcon: Icons.people_outline_rounded,
        trailing: HeaderActionButton(
          icon: Icons.search_rounded,
          tooltip: 'Search customers',
          onPressed: () {
            // Add the customer search feature later.
          },
        ),
        child: cases.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('No customers found')),
          data: (conversations) {
            final customers = conversations
                .map((item) => item.customer)
                .toList();
            return customers.isEmpty
                ? const Center(child: Text('No customers found'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                    itemCount: customers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final customer = customers[index];

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          onTap: () {
                            context.push(
                              AppRoutes.customerDetailsPath(customer.id),
                            );
                          },
                          leading: CustomerAvatar(name: customer.displayName),
                          title: Text(
                            customer.displayName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            customer.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.secondaryText),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}
