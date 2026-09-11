import 'package:flutter/material.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAppText extends StatelessWidget {
  final String data;
  final Color? color;
  final double? size;
  final FontWeight? weight;
  final TextDecoration? decorate;
  final TextAlign? align;
  final int? maxLines;
  final double? lineHeight;
  final TextOverflow? overflow;
  final FontStyle? fontStyle;
  final bool? softWrap;
  final TextStyle? style;

  const MyAppText({
    super.key,
    required this.data,
    this.color,
    this.size,
    this.weight,
    this.decorate,
    this.align,
    this.maxLines,
    this.lineHeight,
    this.overflow,
    this.fontStyle,
    this.softWrap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      softWrap: softWrap ?? true,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: align ?? TextAlign.left,
      maxLines: maxLines ?? 2,
      style: style ??
          TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: size ?? 16.sp,
            fontWeight: weight ?? FontWeight.normal,
            decoration: decorate ?? TextDecoration.none,
            height: lineHeight ?? 1.2,
            fontStyle: fontStyle ?? FontStyle.normal,
          ),
    );
  }
}


