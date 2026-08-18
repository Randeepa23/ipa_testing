import 'package:flutter/material.dart';

import '../config/app_config.dart';

class AppTypography {
  static TextTheme textTheme(AppConfig config, TextTheme base) {
    if (config.useFontFallback) {
      return base.copyWith(
        displayLarge: base.displayLarge?.copyWith(
          fontFamily: 'Libre Baskerville',
        ),
        displayMedium: base.displayMedium?.copyWith(
          fontFamily: 'Libre Baskerville',
        ),
        displaySmall: base.displaySmall?.copyWith(
          fontFamily: 'Libre Baskerville',
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          fontFamily: 'Libre Baskerville',
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontFamily: 'Libre Baskerville',
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontFamily: 'Libre Baskerville',
        ),
        titleLarge: base.titleLarge?.copyWith(fontFamily: 'Libre Baskerville'),
        titleMedium: base.titleMedium?.copyWith(
          fontFamily: 'Libre Baskerville',
        ),
        titleSmall: base.titleSmall?.copyWith(fontFamily: 'Libre Baskerville'),
        bodyLarge: base.bodyLarge?.copyWith(fontFamily: 'Libre Baskerville'),
        bodyMedium: base.bodyMedium?.copyWith(fontFamily: 'Libre Baskerville'),
        bodySmall: base.bodySmall?.copyWith(fontFamily: 'Libre Baskerville'),
        labelLarge: base.labelLarge?.copyWith(fontFamily: 'Libre Baskerville'),
        labelMedium: base.labelMedium?.copyWith(
          fontFamily: 'Libre Baskerville',
        ),
        labelSmall: base.labelSmall?.copyWith(fontFamily: 'Libre Baskerville'),
      );
    }

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontFamily: 'Georgia'),
      displayMedium: base.displayMedium?.copyWith(fontFamily: 'Georgia'),
      displaySmall: base.displaySmall?.copyWith(fontFamily: 'Georgia'),
      headlineLarge: base.headlineLarge?.copyWith(fontFamily: 'Georgia'),
      headlineMedium: base.headlineMedium?.copyWith(fontFamily: 'Georgia'),
      headlineSmall: base.headlineSmall?.copyWith(fontFamily: 'Georgia'),
      titleLarge: base.titleLarge?.copyWith(fontFamily: 'Georgia'),
      titleMedium: base.titleMedium?.copyWith(fontFamily: 'Georgia'),
      titleSmall: base.titleSmall?.copyWith(fontFamily: 'Georgia'),
      bodyLarge: base.bodyLarge?.copyWith(fontFamily: 'Georgia'),
      bodyMedium: base.bodyMedium?.copyWith(fontFamily: 'Georgia'),
      bodySmall: base.bodySmall?.copyWith(fontFamily: 'Georgia'),
      labelLarge: base.labelLarge?.copyWith(fontFamily: 'Georgia'),
      labelMedium: base.labelMedium?.copyWith(fontFamily: 'Georgia'),
      labelSmall: base.labelSmall?.copyWith(fontFamily: 'Georgia'),
    );
  }
}
