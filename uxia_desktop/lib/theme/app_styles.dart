import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF8bc6cc);
  static const Color secondary = Color(0xFF476568);
  static const Color background = Color(0xFFFFFFFF);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppSizes {
  AppSizes._();

  static const double logoHeightMobile = 100;
  static const double logoHeightDesktop = 220;
  static const double appBarHeightMobile = 60;
  static const double appBarHeightDesktop = 90;
  static const double buttonWidthDesktop = 280;
  static const double buttonFontMobile = 16;
  static const double buttonFontDesktop = 18;
  static const double buttonVerticalDesktop = 20;
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle? headlineSmall(BuildContext context, {double? fontSize}) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const borderRadius = BorderRadius.all(Radius.circular(16));
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.background,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8FAFB),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
        ),
        elevation: 8,
        shadowColor: AppColors.primary.withValues(alpha: 0.08),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.12), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.12), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
        labelStyle: TextStyle(color: AppColors.secondary.withValues(alpha: 0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.15),
          backgroundColor: AppColors.background.withValues(alpha: 0.85),
          foregroundColor: AppColors.secondary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
          animationDuration: const Duration(milliseconds: 140),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(MaterialState.pressed)) {
                return AppColors.primary.withValues(alpha: 0.15);
              }
              if (states.contains(MaterialState.hovered)) {
                return AppColors.primary.withValues(alpha: 0.08);
              }
              return null;
            },
          ),
          elevation: MaterialStateProperty.resolveWith<double>(
            (states) => states.contains(MaterialState.pressed) ? 1 : 2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.15),
          backgroundColor: AppColors.primary.withValues(alpha: 0.85),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
          animationDuration: const Duration(milliseconds: 140),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.white.withValues(alpha: 0.15);
              }
              if (states.contains(MaterialState.hovered)) {
                return Colors.white.withValues(alpha: 0.08);
              }
              return null;
            },
          ),
          elevation: MaterialStateProperty.resolveWith<double>(
            (states) => states.contains(MaterialState.pressed) ? 1 : 2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class AppButtonStyles {
  AppButtonStyles._();

  static ButtonStyle elevated({required bool isMobile}) {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? AppSpacing.md : AppSizes.buttonVerticalDesktop,
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
      ),
    );
  }
}

class AppInsets {
  AppInsets._();

  static EdgeInsets screenPadding({required bool isMobile}) {
    return EdgeInsets.symmetric(
      horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
      vertical: isMobile ? AppSpacing.lg : AppSpacing.xl,
    );
  }
}
