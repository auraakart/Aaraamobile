import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';

class MyAppOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;

  const MyAppOutlineButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.borderColor,
    this.textColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.fontSize = 14,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedText = textColor ?? AppColors.brandPrimary;
    final resolvedBorder = borderColor ?? AppColors.brandPrimary;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon != null
          ? Icon(icon, color: resolvedText, size: 18)
          : const SizedBox.shrink(),
      label: MyAppText(
        data: label,
        style: TextStyle(
          color: resolvedText,
          fontWeight: fontWeight,
          fontSize: fontSize,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: resolvedBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
    );
  }
}


