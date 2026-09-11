import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final VoidCallback? onLeadingTap;
  final bool showLeading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;

  const MyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.onLeadingTap,
    this.showLeading = true,
    this.centerTitle = false,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.white,
      surfaceTintColor: backgroundColor ?? AppColors.backgroundBase,
      elevation: 0,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: false,
      title: title,
      centerTitle: centerTitle,
      leading: showLeading
          ? IconButton(
              onPressed: onLeadingTap ?? () => context.pop(true),
              icon: const Icon(EvaIcons.arrow_back_outline),
            )
          : null,
      actions: actions,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));
}


