import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:flutter/material.dart';

class AppColors {
  static Color get brandPrimary => BrandConfig.instance.theme.primary;
  static Color get brandPrimaryDark => BrandConfig.instance.theme.primaryDark;
  static Color get brandSecondary => BrandConfig.instance.theme.secondary;

  static Color get backgroundBase => BrandConfig.instance.theme.backgroundBase;
  static Color get backgroundSurface =>
      BrandConfig.instance.theme.backgroundSurface;
  static Color get backgroundElevated =>
      BrandConfig.instance.theme.backgroundElevated;

  static Color get textPrimary => BrandConfig.instance.theme.textPrimary;
  static Color get textSecondary => BrandConfig.instance.theme.textSecondary;
  static Color get textTertiary => BrandConfig.instance.theme.textTertiary;
  static Color get textDisabled => BrandConfig.instance.theme.textDisabled;

  static Color get success => brandPrimary;
  static Color get warning => brandSecondary;
  static Color get error => BrandConfig.instance.theme.error;

  static Color get badgeSuccess => success;
  static Color get badgeError => error;

  static Color get borderDefault => BrandConfig.instance.theme.borderDefault;
  static Color get borderDisabled => BrandConfig.instance.theme.borderDisabled;

  static Color get shimmerBaseLight =>
      BrandConfig.instance.theme.shimmerBaseLight;
  static Color get shimmerBaseDark =>
      BrandConfig.instance.theme.shimmerBaseDark;
  static Color get shimmerDragLight =>
      BrandConfig.instance.theme.shimmerDragLight;
  static Color get shimmerDragDark =>
      BrandConfig.instance.theme.shimmerDragDark;

  static Color get white => BrandConfig.instance.theme.white;
  static Color get black => textPrimary;
  static Color get transparent => Colors.transparent;

  static Color get pauseWarning => warning;
  static Color get pauseBg => warning.withValues(alpha: 0.12);
  static Color get deliveryBg => success.withValues(alpha: 0.10);
  static Color get cardBackground => backgroundSurface;
  static Color get divider => borderDefault;

  static Color get calendarUnselectedBg => backgroundElevated;
  static Color get calendarSelectedBg => textPrimary;
  static Color get calendarDotActive => textSecondary;
  static Color get calendarDotInactive => borderDefault;
  static Color get calendarCardBg => backgroundElevated;
  static Color get calendarItemIconBg => borderDisabled;
}


