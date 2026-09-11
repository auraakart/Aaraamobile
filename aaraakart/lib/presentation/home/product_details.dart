import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/app/utils/html_to_clean_text.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_state.dart';
import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/create_sub_route_model.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';
import 'package:aaraa_kart/data/model/subscription_product_detail_model.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_shimmer.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/widgets/build_cart_icon.dart';
import 'package:aaraa_kart/presentation/widgets/build_msg_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productID;
  final String productName;
  final List<SubscriptionProductDetailModel>? subProductDetails;
  final bool hasSubscribed;

  const ProductDetailsScreen({
    super.key,
    required this.productID,
    required this.productName,
    required this.hasSubscribed,
    this.subProductDetails,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? productDetails;
  bool loading = true;
  bool isSubscribed = false;
  int currentImageIndex = 0;
  bool isDescriptionExpanded = false;

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<double> _collapseProgress = ValueNotifier<double>(0);

  final ValueNotifier<int> _quantity = ValueNotifier<int>(1);

  double get _heroHeight => 300.h;

  @override
  void initState() {
    super.initState();
    // isSubscribed = widget.hasSubscribed;
    _scrollController.addListener(_onScroll);
    handleProductAPI();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    _quantity.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final double range =
        _heroHeight - kToolbarHeight - MediaQuery.of(context).padding.top;
    _collapseProgress.value =
        (_scrollController.offset / (range <= 0 ? 1 : range)).clamp(0.0, 1.0);
  }

  void handleProductAPI() {
    context.read<ProductCubit>().getProductDetails(widget.productID);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is GetProductDetailsLoading) {
          loading = true;
        } else if (state is GetProductDetailsSuccess) {
          productDetails = state.productDetails;
          loading = false;
          final product = state.productDetails;
          if (product != null) {
            context.read<CartCubit>().syncStockFromProducts([product]);
          }
        } else if (state is GetProductDetailsError) {
          loading = false;
        }
      },
      builder: (context, state) {
        final bool showPlainAppBar = loading || productDetails == null;

        return Scaffold(
          backgroundColor: AppColors.backgroundBase,
          appBar: showPlainAppBar
              ? MyAppBar(
                  title: MyAppText(
                    data: widget.productName,
                    maxLines: 1,
                    weight: FontWeight.w600,
                  ),
                  backgroundColor: AppColors.backgroundBase,
                  actions: [
                    CartIconButton(),
                  ],
                )
              : null,
          body: loading
              ? _buildLoadingSkeleton()
              : productDetails == null
                  ? Center(
                      child: buildMsgState(
                        context,
                        'Unable to load the product.',
                        'Please try again.',
                        () => handleProductAPI(),
                        'Try Again',
                        Iconsax.warning_2_outline,
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(child: _buildScrollableContent()),
                        _buildBottomActionsSection(),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        _buildHeroAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeaderSection(),
                SizedBox(height: 14.h),
                _buildHighlightsSection(),
                // if (_hasSubscriptionPlans) ...[
                //   SizedBox(height: 14.h),
                //   _buildSubscriptionBanner(),
                // ],
                if (productDetails!.shortDescription != null &&
                    productDetails!.shortDescription != "") ...[
                  SizedBox(height: 14.h),
                  _buildAboutSection(),
                ],
                SizedBox(height: 150),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Hero image gallery
  // ---------------------------------------------------------------------------

  Widget _buildHeroAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      expandedHeight: _heroHeight,
      backgroundColor: AppColors.backgroundSurface,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => context.pop(true),
        icon: Icon(
          EvaIcons.arrow_back_outline,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [CartIconButton()],
      title: ValueListenableBuilder<double>(
        valueListenable: _collapseProgress,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: child,
        ),
        child: MyAppText(
          data: productDetails?.name ?? widget.productName,
          maxLines: 1,
          size: 15.sp,
          weight: FontWeight.w600,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImageSection(),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildImageSection() {
    final images = productDetails?.images ?? [];

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.white.withOpacity(0.10),
                AppColors.white,
              ],
            ),
          ),
        ),
        if (images.isEmpty)
          Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 72.r,
              color: AppColors.textDisabled,
            ),
          )
        else
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: _heroHeight,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: false,
              onPageChanged: (index, reason) {
                setState(() {
                  currentImageIndex = index;
                });
              },
            ),
            items: images.map((image) {
              return Padding(
                padding: EdgeInsets.fromLTRB(24.w, 70.h, 24.w, 46.h),
                child: MyAppCachedImage(
                  imageUrl: image.src.toString(),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorWidget: Icon(
                    Icons.image_not_supported_outlined,
                    size: 72.r,
                    color: AppColors.textDisabled,
                  ),
                ),
              );
            }).toList(),
          ),
        // Fades the artwork out as the header collapses into the toolbar.
        ValueListenableBuilder<double>(
          valueListenable: _collapseProgress,
          builder: (context, value, _) => IgnorePointer(
            child: ColoredBox(
              color: AppColors.backgroundSurface.withOpacity(value),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 36.h,
            child: _buildPageIndicator(images.length),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -1,
          child: Container(
            height: 26.h,
            decoration: BoxDecoration(
              color: AppColors.backgroundBase,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => GestureDetector(
          onTap: () => _carouselController.animateToPage(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: currentImageIndex == i ? 18.w : 6.w,
            height: 6.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              color: currentImageIndex == i
                  ? AppColors.brandPrimary
                  : AppColors.brandPrimary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeaderSection() {
    return _surfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_categoryName != null)
                Flexible(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: MyAppText(
                      data: _categoryName!,
                      size: 9.sp,
                      maxLines: 1,
                      weight: FontWeight.w600,
                      color: AppColors.brandPrimaryDark,
                    ),
                  ),
                ),
              const Spacer(),
              if (_hasRealRating) _buildRatingPill(),
            ],
          ),
          if (_isOutOfStock) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.badgeError,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.info_circle_bold,
                      size: 12.r, color: Colors.white),
                  SizedBox(width: 6.w),
                  MyAppText(
                    data: 'Out of Stock',
                    size: 10.sp,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 10.h),
          MyAppText(
            data: productDetails!.name.toString(),
            size: 16.sp,
            weight: FontWeight.w700,
            color: AppColors.textPrimary,
            lineHeight: 1.35,
            maxLines: 3,
          ),
          if (productDetails!.weight != null && productDetails!.weight != "")
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.scale_outlined,
                    size: 13.r,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(width: 5.w),
                  MyAppText(
                    data: productDetails!.weight.toString(),
                    size: 11.sp,
                    weight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          SizedBox(height: 14.h),
          Container(height: 1, color: AppColors.borderDefault),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyAppText(
                data: '₹${_formatAmount(_unitPrice)}',
                size: 24.sp,
                weight: FontWeight.w700,
                color: AppColors.brandPrimaryDark,
              ),
              if (_hasDiscount) ...[
                SizedBox(width: 8.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: MyAppText(
                    data: '₹${_formatAmount(_regularPriceValue!)}',
                    size: 12.sp,
                    decorate: TextDecoration.lineThrough,
                    color: AppColors.textTertiary,
                  ),
                ),
                SizedBox(width: 8.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: MyAppText(
                      data: '$_discountPercent% OFF',
                      size: 9.sp,
                      weight: FontWeight.w700,
                      color: AppColors.brandPrimaryDark,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // SizedBox(height: 4.h),
          // MyAppText(
          //   data: 'Inclusive of all taxes',
          //   size: 9.sp,
          //   color: AppColors.textTertiary,
          // ),
        ],
      ),
    );
  }

  Widget _buildRatingPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 13.r),
          SizedBox(width: 3.w),
          MyAppText(
            data:
                double.parse(productDetails!.averageRating!).toStringAsFixed(1),
            size: 10.sp,
            weight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          SizedBox(width: 3.w),
          MyAppText(
            data: '(${productDetails!.ratingCount})',
            size: 9.sp,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection() {
    Widget tile(IconData icon, String title, String subtitle) {
      return Expanded(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(9.r),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16.r, color: AppColors.brandPrimary),
            ),
            SizedBox(height: 8.h),
            MyAppText(
              data: title,
              size: 10.sp,
              weight: FontWeight.w700,
              align: TextAlign.center,
              maxLines: 1,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 2.h),
            MyAppText(
              data: subtitle,
              size: 8.sp,
              align: TextAlign.center,
              maxLines: 1,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      );
    }

    Widget separator() => Container(
          width: 1,
          height: 44.h,
          color: AppColors.borderDefault,
        );

    return _surfaceCard(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          tile(Iconsax.truck_fast_outline, 'Fast Delivery', 'On Doorstep'),
          separator(),
          tile(Iconsax.star_1_outline, 'Premium', 'Hand picked'),
          separator(),
          tile(Iconsax.heart_circle_outline, 'Farm Fresh', 'Direct source'),
        ],
      ),
    );
  }

  // Widget _buildSubscriptionBanner() {
  //   final double? bestDiscount = _bestSubscriptionDiscount;
  //   final String subtitle = isSubscribed
  //       ? 'Manage your schedule or add another plan.'
  //       : bestDiscount != null
  //           ? 'Save up to ${_formatAmount(bestDiscount)}% on every scheduled delivery.'
  //           : 'Get it delivered automatically on your schedule.';

  //   return GestureDetector(
  //     onTap: _openSubscriptionFlow,
  //     child: Container(
  //       padding: EdgeInsets.all(14.r),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(18.r),
  //         border: Border.all(color: AppColors.brandPrimary.withOpacity(0.20)),
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             padding: EdgeInsets.all(9.r),
  //             decoration: BoxDecoration(
  //               color: AppColors.backgroundSurface,
  //               shape: BoxShape.circle,
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: AppColors.brandPrimary.withOpacity(0.15),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Icon(
  //               isSubscribed
  //                   ? Icons.check_circle_rounded
  //                   : Iconsax.discount_shape_bold,
  //               size: 16.r,
  //               color: AppColors.brandPrimary,
  //             ),
  //           ),
  //           SizedBox(width: 12.w),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 MyAppText(
  //                   data: isSubscribed
  //                       ? 'You are subscribed'
  //                       : 'Subscribe & Save',
  //                   size: 12.sp,
  //                   weight: FontWeight.w700,
  //                   maxLines: 1,
  //                   color: AppColors.textPrimary,
  //                 ),
  //                 SizedBox(height: 3.h),
  //                 MyAppText(
  //                   data: subtitle,
  //                   size: 9.5.sp,
  //                   lineHeight: 1.35,
  //                   color: AppColors.textSecondary,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           SizedBox(width: 6.w),
  //           Icon(
  //             Icons.chevron_right_rounded,
  //             size: 20.r,
  //             color: AppColors.brandPrimary,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAboutSection() {
    final String description = _getDescriptionText();
    final bool isLongText = description.length > 180;

    return _surfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Iconsax.note_1_bold,
                  size: 15.r,
                  color: AppColors.brandPrimary,
                ),
              ),
              SizedBox(width: 10.w),
              MyAppText(
                data: 'About This Product',
                size: 13.sp,
                weight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          MyAppText(
            data: description,
            size: 11.5.sp,
            lineHeight: 1.55,
            color: AppColors.textSecondary,
            maxLines: isDescriptionExpanded ? 100 : 4,
          ),
          if (isLongText)
            GestureDetector(
              onTap: () => setState(
                () => isDescriptionExpanded = !isDescriptionExpanded,
              ),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Row(
                  children: [
                    MyAppText(
                      data: isDescriptionExpanded ? 'Read less' : 'Read more',
                      size: 11.sp,
                      weight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      isDescriptionExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16.r,
                      color: AppColors.brandPrimary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _surfaceCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppColors.backgroundSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBottomActionsSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: _isOutOfStock
            ? _buildOutOfStockBar()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuantityRow(),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      if (_hasSubscriptionPlans) ...[
                        Expanded(child: _buildSubscribeButton()),
                        SizedBox(width: 12.w),
                      ],
                      Expanded(child: _buildAddToCartButton()),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOutOfStockBar() {
    return Container(
      height: 40.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.backgroundBase,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderDisabled, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.bag_cross_1_outline,
            size: 16.r,
            color: AppColors.textDisabled,
          ),
          SizedBox(width: 8.w),
          MyAppText(
            data: 'Out of Stock',
            size: 12.sp,
            maxLines: 1,
            weight: FontWeight.w700,
            color: AppColors.textDisabled,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      children: [
        MyAppText(
          data: 'Quantity',
          size: 11.sp,
          weight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 12.w),
        _buildQuantitySelector(),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            MyAppText(
              data: 'Total',
              size: 9.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 2.h),
            ValueListenableBuilder<int>(
              valueListenable: _quantity,
              builder: (context, quantity, _) => MyAppText(
                data: '₹${_formatAmount(_unitPrice * quantity)}',
                size: 18.sp,
                maxLines: 1,
                weight: FontWeight.w700,
                color: AppColors.brandPrimaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    Widget segment({
      required IconData icon,
      required bool enabled,
      required Color background,
      required Color iconColor,
      required VoidCallback onTap,
    }) {
      return Material(
        color: background,
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          child: SizedBox(
            width: 34.w,
            child: Center(child: Icon(icon, size: 16.r, color: iconColor)),
          ),
        ),
      );
    }

    return Container(
      height: 30.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.brandPrimary.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _quantity,
        builder: (context, quantity, _) {
          final bool canDecrease = quantity > 1;

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              segment(
                icon: Icons.remove_rounded,
                enabled: canDecrease,
                background: AppColors.backgroundBase,
                iconColor: canDecrease
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
                onTap: () => _quantity.value = quantity - 1,
              ),
              SizedBox(
                width: 30.w,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: MyAppText(
                      key: ValueKey<int>(quantity),
                      data: '$quantity',
                      align: TextAlign.center,
                      weight: FontWeight.w700,
                      size: 13.sp,
                      color: AppColors.brandPrimaryDark,
                    ),
                  ),
                ),
              ),
              segment(
                icon: Icons.add_rounded,
                enabled: true,
                background: AppColors.brandPrimary,
                iconColor: Colors.white,
                onTap: () => _quantity.value = quantity + 1,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return _barButton(
      onTap: _handleAddToCart,
      background: AppColors.brandPrimary,
      borderColor: AppColors.brandPrimary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.bag_2_bold, size: 16.r, color: Colors.white),
          SizedBox(width: 8.w),
          MyAppText(
            data: 'Add to Cart',
            size: 12.sp,
            maxLines: 1,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return _barButton(
      onTap: _openSubscriptionFlow,
      background:
          isSubscribed ? AppColors.brandPrimary : AppColors.backgroundSurface,
      borderColor: AppColors.brandPrimary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSubscribed
                ? Icons.check_circle_rounded
                : Iconsax.discount_shape_bold,
            size: 16.r,
            color: isSubscribed ? Colors.white : AppColors.brandPrimary,
          ),
          SizedBox(width: 8.w),
          MyAppText(
            data: isSubscribed ? 'Subscribed' : 'Subscribe',
            size: 12.sp,
            maxLines: 1,
            weight: FontWeight.w700,
            color: isSubscribed ? Colors.white : AppColors.brandPrimary,
          ),
        ],
      ),
    );
  }

  Widget _barButton({
    required VoidCallback onTap,
    required Color background,
    required Color borderColor,
    required Widget child,
  }) {
    final BorderRadius radius = BorderRadius.circular(14.r);

    return Material(
      color: background,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 40.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: FittedBox(fit: BoxFit.scaleDown, child: child),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    Widget bone({double? width, required double height, double radius = 8}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      );
    }

    return MyAppShimmer(
      isLoading: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: bone(
                width: double.infinity,
                height: 220.h,
                radius: 20,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bone(width: 90.w, height: 18.h),
                  SizedBox(height: 12.h),
                  bone(width: double.infinity, height: 16.h),
                  SizedBox(height: 8.h),
                  bone(width: 160.w, height: 16.h),
                  SizedBox(height: 18.h),
                  bone(width: 120.w, height: 26.h),
                  SizedBox(height: 22.h),
                  bone(width: double.infinity, height: 78.h, radius: 20),
                  SizedBox(height: 16.h),
                  bone(width: double.infinity, height: 120.h, radius: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _handleAddToCart() {
    final productId = productDetails!.id.toString();
    final images = productDetails!.images;

    context.read<CartCubit>().addItemQuantity(
          CartItem(
            id: productId,
            name: productDetails!.name.toString(),
            price: _getPrice(),
            quantity: _quantity.value,
            imageUrl: (images != null && images.isNotEmpty)
                ? images[0].src.toString()
                : '',
          ),
          context,
        );

    _quantity.value = 1;
  }

  Future<void> _openSubscriptionFlow() async {
    final result = await context.push('/create-subscription', extra: {
      'productDetails': CreateSubRouteModel(
        productID: productDetails!.id.toString(),
        subscriptionPlans: productDetails!.subscriptionPlans,
        price: _getPrice(),
        advanceAmount: productDetails!.advanceAmount ?? 0,
        productName: productDetails!.name,
        image: productDetails!.images!.isNotEmpty
            ? productDetails!.images![0].src.toString()
            : '',
      ),
    });

    if (result == true && mounted) {
      setState(() {
        isSubscribed = true;
      });
      handleProductAPI();
    }
  }

  String _getPrice() => (productDetails?.salePrice?.isEmpty ?? true)
      ? (productDetails?.regularPrice ?? '')
      : productDetails!.salePrice!;

  double get _unitPrice => double.tryParse(_getPrice()) ?? 0;

  double? get _regularPriceValue =>
      double.tryParse(productDetails?.regularPrice ?? '');

  bool get _hasDiscount {
    final regular = _regularPriceValue;
    final sale = double.tryParse(productDetails?.salePrice ?? '');
    return regular != null && sale != null && sale > 0 && sale < regular;
  }

  int get _discountPercent {
    final regular = _regularPriceValue!;
    final sale = double.parse(productDetails!.salePrice!);
    return (((regular - sale) / regular) * 100).round();
  }

  bool get _hasSubscriptionPlans =>
      productDetails?.subscriptionPlans?.isNotEmpty ?? false;

  bool get _isOutOfStock => productDetails?.isOutOfStock ?? false;

  double? get _bestSubscriptionDiscount {
    final plans = productDetails?.subscriptionPlans;
    if (plans == null || plans.isEmpty) return null;

    double best = 0;
    for (final plan in plans) {
      final discount = double.tryParse(plan.discount ?? '');
      if (discount != null && discount > best) best = discount;
    }
    return best > 0 ? best : null;
  }

  String? get _categoryName {
    final categories = productDetails?.categories;
    if (categories == null || categories.isEmpty) return null;
    return categories.first.name;
  }

  bool get _hasRealRating {
    final rating = double.tryParse(productDetails?.averageRating ?? '');
    return rating != null &&
        rating > 0 &&
        (productDetails?.ratingCount ?? 0) > 0;
  }

  String _formatAmount(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  String _getDescriptionText() {
    return productDetails!.shortDescription!.isEmpty
        ? 'Fresh and organic produce sourced directly from local farms. Our products are harvested at the peak of their flavor and nutrition, ensuring you get the best quality and taste.'
        : htmlToCleanText(productDetails!.shortDescription.toString());
  }
}
