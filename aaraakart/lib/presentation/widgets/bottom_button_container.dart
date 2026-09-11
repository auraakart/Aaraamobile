import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomButtonContainer extends StatelessWidget {
  final List<Widget> widgets;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;

  const BottomButtonContainer({
    super.key,
    required this.widgets,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.fromLTRB(20.r, 0, 20.r, 10.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius ?? 30.r),
          topRight: Radius.circular(borderRadius ?? 30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: widgets,
        ),
      ),
    );
  }
}


