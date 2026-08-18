import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';

class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 44,
  });

  final String name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final initials = name.trim().isEmpty
        ? 'GC'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((value) => value.characters.first.toUpperCase())
              .join();

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.paleBlue,
      backgroundImage: hasImage ? CachedNetworkImageProvider(imageUrl!) : null,
      child: !hasImage
          ? Text(
              initials,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primaryDarkBlue,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}
