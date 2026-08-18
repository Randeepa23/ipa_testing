import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../core/widgets/screen_header_shell.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import 'change_password_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final rep = state.representative;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: ScreenHeaderShell(
        title: 'More',
        subtitle: 'Profile, availability and settings',
        leadingIcon: Icons.more_horiz_rounded,
        trailing: HeaderActionButton(
          icon: Icons.person_outline_rounded,
          tooltip: 'Representative profile',
          onPressed: () {},
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          children: [
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                leading: CustomerAvatar(name: rep.name, size: 54),
                title: Text(
                  rep.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${rep.department} • ${rep.role}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _InfoTile(title: 'Email', value: rep.email),
            _InfoTile(
              title: 'Availability',
              value: _availabilityText(rep.availabilityStatus.name),
            ),
            _InfoTile(
              title: 'Conversations handled today',
              value: '${state.conversationsHandledToday}',
            ),
            _InfoTile(
              title: 'Average response time',
              value: state.averageResponseTime,
            ),
            const SizedBox(height: 18),
            Text(
              'Notification preferences',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...state.notificationPreferences.entries.map((entry) {
              // ScreenHeaderShell uses a ColoredBox for its content area.
              // SwitchListTile needs its own Material so its state and ink
              // effects are not hidden behind that background.
              return Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  value: entry.value,
                  activeTrackColor: AppColors.primaryDarkBlue,
                  onChanged: (value) {
                    ref
                        .read(profileControllerProvider.notifier)
                        .updateNotificationPreference(entry.key, value);
                  },
                  title: Text(entry.key),
                ),
              );
            }),
            const SizedBox(height: 18),
            FilledButton.tonal(
              onPressed: () async {
                final input = await showDialog<ChangePasswordInput>(
                  context: context,
                  builder: (context) {
                    return const ChangePasswordDialog();
                  },
                );

                if (input == null || !context.mounted) {
                  return;
                }

                final errorMessage = await ref
                    .read(profileControllerProvider.notifier)
                    .changePassword(
                      currentPassword: input.currentPassword,
                      newPassword: input.newPassword,
                    );

                if (!context.mounted) {
                  return;
                }

                if (errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  );

                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your password was changed successfully.'),
                  ),
                );
              },
              child: const Text('Change password'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.white,
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return const ConfirmationDialog(
                      title: 'Log out?',
                      message:
                          'You will need to sign in again to access customer conversations.',
                      confirmLabel: 'Logout',
                      cancelLabel: 'Cancel',
                    );
                  },
                );

                if (confirmed != true || !context.mounted) {
                  return;
                }

                await ref.read(loginControllerProvider.notifier).signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  String _availabilityText(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.mainText),
          ),
        ),
      ),
    );
  }
}
