import 'package:aaraa_kart/app/router/app_routes.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/app/utils/get_initials.dart';
import 'package:aaraa_kart/cubit/category/category_cubit.dart';
import 'package:aaraa_kart/cubit/category/category_state.dart';
import 'package:aaraa_kart/data/model/category_list_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_shimmer.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProductCategories extends StatefulWidget {
  const ProductCategories({super.key});

  @override
  State<ProductCategories> createState() => _ProductCategoriesState();
}

class _ProductCategoriesState extends State<ProductCategories> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 50.h, child: _buildProductCategories());
  }

  @override
  void initState() {
    final categoryCubit = context.read<CategoryCubit>();
    final categoryState = categoryCubit.state;
    if (categoryState is CategorySuccess && categoryState.categorys != null) {
    } else {
      context.read<CategoryCubit>().getCategoryList();
    }
    super.initState();
  }

  Widget _buildProductCategories() {
    return BlocConsumer<CategoryCubit, CategoryState>(
      listener: (context, state) {},
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        List<CategoryProduct>? productCategories =
            state is CategorySuccess ? state.categorys : [];

        return MyAppShimmer(
          isLoading: state is CategoryLoading,
          child: state is CategoryLoading
              ? Container(
                  child: ListView.separated(
                      itemCount: 7,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 16.w),
                      itemBuilder: (context, index) {
                        return _buildShimmerItem();
                      }),
                )
              : Container(
                  child: ListView.separated(
                      itemCount: productCategories!.length,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 16.w),
                      itemBuilder: (context, index) {
                        return _buildCategoryItem(
                          context,
                          productCategories[index],
                          index,
                        );
                      }),
                ),
        );
      },
    );
  }

  Widget _buildShimmerItem() {
    return SizedBox(
      width: 40.w,
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: 32.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryProduct category,
    int index,
  ) {
    final imageUrl = category.image?.src;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.productList.name,
          extra: {'appTitle': "Categories", 'category': category.name ?? "All"},
        );
      },
      child: SizedBox(
        width: 40.w,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40.w,
              height: 40.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.badgeSuccess,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: hasImage
                  ? MyAppCachedImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: 40.w,
                      height: 40.w,
                      errorWidget: _buildCategoryInitials(category.name),
                    )
                  : _buildCategoryInitials(category.name),
            ),
            SizedBox(height: 4.h),
            MyAppText(
              data: category.name ?? "",
              size: 8.sp,
              weight: FontWeight.w600,
              color: AppColors.textPrimary,
              align: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInitials(String? name) {
    return Center(
      child: MyAppText(
        data: getInitials(name),
        size: 14.sp,
        weight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}


