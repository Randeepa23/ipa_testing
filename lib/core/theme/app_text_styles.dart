import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTextStyles {
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      color: AppColors.mainText,
      fontWeight: FontWeight.w700,
    );
  }
}
