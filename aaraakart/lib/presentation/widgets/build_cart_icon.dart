import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_state.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class CartIconButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CartIconButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(right: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            constraints: BoxConstraints(
              minWidth: 40.w,
              minHeight: 40.h,
            ),
            padding: EdgeInsets.all(8.h),
            icon: Icon(
              Iconsax.bag_2_bold,
              color: AppColors.brandPrimaryDark,
              size: 20.r,
            ),
            onPressed: onTap ?? () => context.push('/cart'),
          ),
        ),
        BlocConsumer<CartCubit, CartState>(
          listener: (_, __) {},
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            final totalItems = state.items.fold<int>(
              0,
              (sum, item) => sum + (item.quantity ?? 1),
            );
            if (totalItems == 0) return const SizedBox.shrink();

            return Positioned(
              right: 12.w,
              top: 6.h,
              child: Container(
                height: 16.w,
                width: 16.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: MyAppText(
                    data: totalItems.toString(),
                    color: Colors.white,
                    size: 8.sp,
                    weight: FontWeight.bold,
                    align: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}


