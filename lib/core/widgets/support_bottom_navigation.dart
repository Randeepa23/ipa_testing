import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SupportBottomNavigation extends StatelessWidget {
  const SupportBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = <_BottomNavItem>[
      const _BottomNavItem(
        icon: Icons.inbox_outlined,
        activeIcon: Icons.inbox,
        label: 'Inbox',
      ),
      const _BottomNavItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Chats',
      ),
      const _BottomNavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'Customers',
      ),
      const _BottomNavItem(
        icon: Icons.notifications_none,
        activeIcon: Icons.notifications,
        label: 'Alerts',
      ),
      const _BottomNavItem(
        icon: Icons.more_horiz,
        activeIcon: Icons.more_horiz,
        label: 'More',
      ),
    ];

    return ColoredBox(
      color: AppColors.primaryDarkBlue,
      child: SafeArea(
        top: false,
        child: Container(
          height: 74,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primaryDarkBlue, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 14,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.white.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: AppColors.white,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.white,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                // Keep the longer Customers label visible at
                                // the same compact navigation width.
                                fontSize: item.label == 'Customers' ? 9 : 10.5,
                                height: 1.0,
                              ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
