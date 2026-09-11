import 'package:aaraa_kart/app/router/app_routes.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/banner/banner_cubit.dart';
import 'package:aaraa_kart/cubit/category/category_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_shimmer.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/common/my_app_text_field.dart';
import 'package:aaraa_kart/presentation/home/promotional_banner.dart';
import 'package:aaraa_kart/presentation/widgets/CartFab.dart';
import 'package:aaraa_kart/presentation/widgets/build_cart_icon.dart';
import 'package:aaraa_kart/presentation/widgets/home_app_bar_tile.dart';
import 'package:aaraa_kart/presentation/widgets/product_card.dart';
import 'package:aaraa_kart/presentation/widgets/product_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final productState = context.read<ProductCubit>().state;

    if (productState is! ProductSuccess) {
      context.read<ProductCubit>().getProducts("1", "20", null);
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<CategoryCubit>().getCategoryList(),
      context.read<ProductCubit>().getProducts("1", "20", null),
      context.read<BannerCubit>().getMobileBanners(),
    ]);

    if (context.read<StorageCubit>().isGuestMode != true) {
      final customerId = context.read<StorageCubit>().userData?.customerID;
      if (customerId != null && customerId.isNotEmpty) {
        await context.read<AuthCubit>().listAddress(customerId);
        await context.read<StorageCubit>().getAddress();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        showLeading: false,
        title: const HomeAppBarTitle(),
        bottom: _appBarSearch(),
        actions: [
          Container(
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
                MingCute.user_2_fill,
                color: AppColors.brandPrimaryDark,
                size: 20.r,
              ),
              onPressed: () => context.push('/profile'),
            ),
          ),
          CartIconButton()
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 35.h,
        child: CartFAB(),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.brandPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PromotionalBanner(),
              SizedBox(height: 20.h),
              _buildHeaderRow('Categories', 'See all'),
              SizedBox(height: 20.h),
              ProductCategories(),
              SizedBox(height: 15.h),
              _buildHeaderRow('All Products', null),
              SizedBox(height: 15.h),
              _buildAllProducts(),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBarSearch() => PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: GestureDetector(
          onTap: () => context.pushNamed(AppRoutes.productList.name,
              extra: {'appTitle': 'All Categories', 'category': 'All'}),
          child: Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: MyAppTextField(
                enabled: false,
                fillColor: AppColors.white,
                hintText: 'Search for fresh products...',
                isSearch: true,
                borderRadius: 16,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              )),
        ),
      );

  Widget _buildHeaderRow(title, subtitle) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyAppText(
            data: title,
            size: 16.sp,
            weight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          if (subtitle != null)
            GestureDetector(
              onTap: () {
                context.pushNamed(
                  AppRoutes.productList.name,
                  extra: {'appTitle': title, 'category': 'All'},
                );
              },
              child: MyAppText(
                data: subtitle,
                weight: FontWeight.w600,
                size: 11.sp,
                color: AppColors.brandPrimary,
              ),
            ),
        ],
      );

  Widget _buildAllProducts() {
    return BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductSuccess) {
            context.read<CartCubit>().syncStockFromProducts(state.products);
          }
        },
        buildWhen: (previous, current) =>
            current is ProductSuccess ||
            current is ProductLoading ||
            current is ProductError,
        builder: (context, state) {
          bool isLoading = state is ProductLoading;
          final List<dynamic> displayData = isLoading
              ? List.filled(4, null)
              : (state is ProductSuccess ? state.products : []);
          return MyAppShimmer(
            isLoading: isLoading,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.63),
              itemCount: displayData.length,
              itemBuilder: (context, index) {
                final product = displayData[index];
                return ProductCard(
                  key: ValueKey(product?.id ?? 'placeholder-$index'),
                  product: product,
                );
              },
            ),
          );
        });
  }
}


