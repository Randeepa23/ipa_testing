import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../providers.dart';

class ScreenHeaderShell extends ConsumerWidget {
  const ScreenHeaderShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.child,
    this.trailing,
    this.onLeadingPressed,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onLeadingPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(companyBrandProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Column(
        children: [
          // Blue branded upper section.
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primaryDarkBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _HeaderLeadingButton(
                      logoAsset: brand.logoAsset,
                      onPressed: onLeadingPressed,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 21,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),

          // White/light content area.
          Expanded(
            child: ColoredBox(
              color: AppColors.lightBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The subtitle is now shown below the blue header.
                  if (subtitle.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.primaryDarkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              letterSpacing: 0.1,
                            ),
                      ),
                    ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderLeadingButton extends StatelessWidget {
  const _HeaderLeadingButton({required this.logoAsset, this.onPressed});

  final String logoAsset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final iconContainer = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE1EAF5)),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ClipOval(
          child: Image.asset(
            logoAsset,
            fit: BoxFit.contain,
            // Brand files are much larger than this 48px header icon.
            // Decode a right-sized image instead of the full source bitmap.
            cacheWidth: 128,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );

    if (onPressed == null) {
      return iconContainer;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: iconContainer,
      ),
    );
  }
}

class HeaderActionButton extends StatelessWidget {
  const HeaderActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Tooltip(
              message: tooltip,
              child: SizedBox(
                width: 46,
                height: 46,
                child: Icon(icon, color: AppColors.white, size: 22),
              ),
            ),
          ),
        ),
        if (showBadge)
          const Positioned(
            top: 4,
            right: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 10, height: 10),
            ),
          ),
      ],
    );
  }
}
