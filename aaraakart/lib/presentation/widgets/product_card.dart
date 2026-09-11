import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/create_sub_route_model.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends StatefulWidget {
  final Product? product;
  final String fromScreen;

  const ProductCard({
    super.key,
    required this.product,
    this.fromScreen = "home",
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  static const String defaultImageUrl =
      "https://thefarmersvillage.in/wp-content/uploads/2022/08/Desi-Buffalo-Milk-Pasteurized-A2-Milk.png";

  bool isSubscribed = false;
  String? qty = "";

  bool get hasSubscription =>
      widget.product?.subscriptionPlans?.isNotEmpty ?? false;

  bool get isOutOfStock => widget.product?.isOutOfStock ?? false;

  String get imageUrl {
    final images = widget.product?.images;
    final src = (images != null && images.isNotEmpty) ? images.first.src : null;
    return (src != null && src.isNotEmpty) ? src : defaultImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final bool isLoading = widget.product == null;
        final String productId =
            isLoading ? '0' : widget.product!.id.toString();

        final itemInCart = isLoading
            ? []
            : cartState.items.where((item) => item.id == productId).toList();

        final int itemCount =
            itemInCart.isEmpty ? 0 : itemInCart.first.quantity;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  context.pushNamed(
                    'productDetails',
                    extra: {
                      'productID': widget.product!.id.toString(),
                      'productName': widget.product!.name,
                    },
                  );
                },
          child: Container(
            width: 155.w,
            margin: EdgeInsets.only(
                left: widget.fromScreen == "home" ? 0 : 6,
                right: widget.fromScreen == "home" ? 0 : 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(10.0.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildImageSection(isLoading, itemCount),
                  _buildProductInfoSection(isLoading, itemCount),
                  _buildActionButtonsSection(isLoading, itemCount),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(bool isLoading, int itemCount) {
    return Expanded(
      flex: 2,
      child: isLoading
          ? _buildShimmerPlaceholder()
          : Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: MyAppCachedImage(
                      key: ValueKey(imageUrl),
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholderWidget: _buildShimmerPlaceholder(),
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badgeError,
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: MyAppText(
                          data: 'OUT OF STOCK',
                          color: Colors.white,
                          size: 8.sp,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.eco,
                      color: Colors.white,
                      size: 14.r,
                    ),
                  ),
                ),
                if (widget.product!.name!.toLowerCase().contains("milk"))
                  Positioned(
                    top: 7.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.badgeError,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: MyAppText(
                        data: 'A2 Milk',
                        color: Colors.white,
                        size: 7.sp,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildProductInfoSection(bool isLoading, int itemCount) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [],
          ),
          SizedBox(height: 6.h),
          if (isLoading)
            _buildLoadingText()
          else
            MyAppText(
              data: widget.product!.name.toString(),
              maxLines: 2,
              weight: FontWeight.bold,
              size: 11.sp,
              color: AppColors.textPrimary,
            ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isLoading)
                _buildLoadingPrice()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyAppText(
                      data: '₹ ${_getPrice()}',
                      weight: FontWeight.w700,
                      size: 14.sp,
                      color: AppColors.brandPrimary,
                    ),
                  ],
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection(bool isLoading, int itemCount) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            Container(
              height: 30.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            )
          else
            _buildActionButtonRow(itemCount),
        ],
      ),
    );
  }

  Widget _buildActionButtonRow(int itemCount) {
    if (isOutOfStock && itemCount == 0) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundBase,
          border: Border.all(color: AppColors.borderDisabled, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: MyAppText(
          data: 'Out of Stock',
          size: 10.sp,
          weight: FontWeight.bold,
          color: AppColors.textDisabled,
        ),
      );
    }

    if (itemCount == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (context.read<StorageCubit>().isGuestMode == false &&
              hasSubscription &&
              !isSubscribed)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.push('/create-subscription', extra: {
                    'productDetails': CreateSubRouteModel(
                        productID: widget.product!.id.toString(),
                        subscriptionPlans: widget.product!.subscriptionPlans,
                        price: _getPrice(),
                        productName: widget.product!.name,
                        advanceAmount: widget.product!.advanceAmount ?? 0,
                        image: imageUrl),
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSubscribed
                        ? AppColors.badgeSuccess
                        : Colors.transparent,
                    border: Border.all(
                      color: AppColors.badgeSuccess,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: MyAppText(
                    data: isSubscribed ? 'Subscribed' : 'Subscribe',
                    size: 10.sp,
                    weight: FontWeight.bold,
                    color: isSubscribed ? Colors.white : AppColors.badgeSuccess,
                  ),
                ),
              ),
            ),
          if (context.read<StorageCubit>().isGuestMode == false &&
              hasSubscription &&
              !isSubscribed)
            SizedBox(width: 6.w),
          GestureDetector(
            onTap: () {
              context.read<CartCubit>().addItem(
                  CartItem(
                    id: widget.product!.id.toString(),
                    name: widget.product!.name.toString(),
                    price: _getPrice(),
                    quantity: 1,
                    imageUrl: imageUrl,
                  ),
                  context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPrimary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: context.read<StorageCubit>().isGuestMode == false &&
                      hasSubscription &&
                      !isSubscribed
                  ? Icon(
                      Icons.add_rounded,
                      color: AppColors.backgroundSurface,
                      size: 14.r,
                    )
                  : Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 14.r,
                            ),
                            SizedBox(width: 4.w),
                            MyAppText(
                              data: 'Add to Cart',
                              color: Colors.white,
                              weight: FontWeight.w600,
                              size: 9.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.brandPrimary,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                context
                    .read<CartCubit>()
                    .removeItem(widget.product!.id.toString());
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundBase,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(7.r),
                    bottomLeft: Radius.circular(7.r),
                  ),
                ),
                child: Icon(
                  Icons.remove_rounded,
                  color: AppColors.textPrimary,
                  size: 14.r,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                alignment: Alignment.center,
                color: Colors.white,
                child: MyAppText(
                  data: '$itemCount',
                  size: 12.sp,
                  color: AppColors.brandPrimary,
                  weight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: isOutOfStock
                  ? null
                  : () {
                      context.read<CartCubit>().addItem(
                          CartItem(
                            id: widget.product!.id.toString(),
                            name: widget.product!.name.toString(),
                            price: _getPrice(),
                            quantity: 1,
                            imageUrl: imageUrl,
                          ),
                          context);
                    },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? AppColors.brandPrimary.withOpacity(0.35)
                      : AppColors.brandPrimary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.backgroundSurface,
                  size: 14.r,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getPrice() => (widget.product?.salePrice?.isEmpty ?? true)
      ? (widget.product?.regularPrice ?? '')
      : widget.product!.salePrice!;
  Widget _buildShimmerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingText() {
    return Container(
      height: 12.h,
      width: 60.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _buildLoadingPrice() {
    return Container(
      height: 16.h,
      width: 50.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}


