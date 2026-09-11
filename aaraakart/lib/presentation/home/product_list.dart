import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/app/utils/get_initials.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/category/category_cubit.dart';
import 'package:aaraa_kart/cubit/category/category_state.dart';
import 'package:aaraa_kart/cubit/product/product_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_state.dart';
import 'package:aaraa_kart/data/model/category_list_response.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/common/my_app_text_field.dart';
import 'package:aaraa_kart/presentation/widgets/CartFab.dart';
import 'package:aaraa_kart/presentation/widgets/build_cart_icon.dart';
import 'package:aaraa_kart/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductListScreen extends StatefulWidget {
  final String appTitle;
  final String category;

  const ProductListScreen({
    super.key,
    required this.appTitle,
    required this.category,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _productList = [];
  List<Product> _filteredProductList = [];
  List<CategoryProduct> _productCategories = [];
  String _selectedCategory = 'All';
  String _selectedSort = 'Popular';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final categoryCubit = context.read<CategoryCubit>();
    final categoryState = categoryCubit.state;

    if (categoryState is CategorySuccess && categoryState.categorys != null) {
      _productCategories = [
        CategoryProduct(name: 'All'),
        ...categoryState.categorys!
      ];
    } else {
      _productCategories = [CategoryProduct(name: 'All')];
      categoryCubit.getCategoryList();
    }

    _selectedCategory = widget.category;

    final productCubit = context.read<ProductCubit>();
    final productState = productCubit.state;

    if (productState is ProductSuccess) {
      _productList = productState.products;
      _filterProductsByCategory(widget.category, null);
    } else {
      context.read<ProductCubit>().getProducts("1", "20", null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: MyAppBar(
        title: MyAppText(data: widget.appTitle),
        actions: [
          CartIconButton(),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: Row(
              children: [
                _buildVerticalCategoriesSection(),
                Expanded(
                  child: _buildProductListSection(context),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 35.h,
        child: CartFAB(),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: MyAppTextField(
                isSearch: true,
                contentPadding: EdgeInsets.all(0),
                controller: _searchController,
                onChanged: (e) {
                  _applyFiltersAndSort();
                },
                hintText: 'Search products...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalCategoriesSection() {
    return Container(
      width: 90.w,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: MyAppText(
              data: 'Categories',
              size: 11.sp,
              weight: FontWeight.bold,
              color: AppColors.brandPrimaryDark,
              align: TextAlign.center,
            ),
          ),
          BlocConsumer<CategoryCubit, CategoryState>(
            listener: _onCategoryStateChanged,
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              if (state is CategoryLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: _productCategories.length,
                  itemBuilder: (context, index) {
                    final categoryData = _productCategories[index];
                    final isSelected = categoryData.name == _selectedCategory;

                    return _buildCategoryItem(
                      categoryData,
                      isSelected,
                      index,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    CategoryProduct categoryData,
    bool isSelected,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _onCategorySelected(categoryData),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandPrimary.withOpacity(0.08)
              : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: isSelected ? AppColors.brandPrimary : Colors.grey.shade200,
              width: isSelected ? 3 : 1,
            ),
            bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
          ),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40.w,
              height: 40.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color:
                    !isSelected ? Colors.grey.shade100 : AppColors.brandPrimary,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.brandPrimary.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: _buildCategoryIcon(categoryData, isSelected),
            ),
            SizedBox(height: 6.h),
            MyAppText(
              data: categoryData.name ?? "",
              size: 8.sp,
              weight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.brandPrimary : Colors.grey.shade700,
              align: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(CategoryProduct categoryData, bool isSelected) {
    final imageUrl = categoryData.image?.src;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final initialsWidget =
        _buildCategoryInitials(categoryData.name, isSelected);

    if (!hasImage) {
      return initialsWidget;
    }

    return MyAppCachedImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: 40.w,
      height: 40.w,
      errorWidget: initialsWidget,
    );
  }

  Widget _buildCategoryInitials(String? name, bool isSelected) {
    return Center(
      child: MyAppText(
        data: getInitials(name),
        size: 12.sp,
        weight: FontWeight.w600,
        color: isSelected ? Colors.white : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildProductListSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBase,
      ),
      child: BlocConsumer<ProductCubit, ProductState>(
        listener: _onProductStateChanged,
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductSuccess) {
            if (_productList.isEmpty) {
              _productList = state.products ?? [];
              _applyFiltersAndSort();
            }
          }

          if (state is ProductError) {
            return _buildErrorState(state.message);
          }

          return _buildProductGrid();
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Column(
      children: [
        _buildProductHeader(),
        Expanded(
          child: _filteredProductList.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  itemCount: _filteredProductList.length,
                  padding: EdgeInsets.all(16.r),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = _filteredProductList[index];
                    return ProductCard(
                      key: ValueKey(product.id),
                      fromScreen: "list",
                      product: product,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: MyAppText(
              data: _selectedCategory,
              size: 11.sp,
              weight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: MyAppText(
              data: '${_filteredProductList.length} items',
              size: 10.sp,
              weight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 48.r,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 16.h),
          MyAppText(
            data: 'No products found',
            color: Colors.grey.shade600,
            size: 14.sp,
            weight: FontWeight.w500,
          ),
          SizedBox(height: 8.h),
          MyAppText(
            data: 'Try adjusting your search or filters',
            color: Colors.grey.shade500,
            size: 12.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48.r,
              color: Colors.red.shade400,
            ),
          ),
          SizedBox(height: 16.h),
          MyAppText(
            data: message ?? 'Error loading products',
            color: Colors.grey.shade700,
            align: TextAlign.center,
            size: 14.sp,
            weight: FontWeight.w500,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<ProductCubit>().getProducts("1", "20", null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _applyFiltersAndSort();
  }

  void _onSortChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedSort = newValue;
      });
      _applyFiltersAndSort();
    }
  }

  void _onCategorySelected(CategoryProduct categoryData) {
    setState(() {
      _selectedCategory = categoryData.name ?? "All";
    });
    _filterProductsByCategory(
      categoryData.name ?? "All",
      categoryData.id?.toString(),
    );
  }

  void _onCategoryStateChanged(BuildContext context, CategoryState state) {
    if (state is CategorySuccess) {
      setState(() {
        _productCategories = [
          CategoryProduct(name: 'All'),
          ...(state.categorys ?? [])
        ];
      });
    } else if (state is CategoryError) {}
  }

  void _onProductStateChanged(BuildContext context, ProductState state) {
    if (state is ProductSuccess) {
      setState(() {
        _productList = state.products ?? [];
      });
      context.read<CartCubit>().syncStockFromProducts(_productList);
      _applyFiltersAndSort();
    } else if (state is ProductError) {}
  }

  void _filterProductsByCategory(String category, String? categoryId) {
    if (category == 'All') {
      if (categoryId != null && categoryId != 'null') {
        context.read<ProductCubit>().getProducts("1", "20", categoryId);
      } else {
        _applyFiltersAndSort();
      }
    } else {
      _applyFiltersAndSort();
    }
  }

  void _applyFiltersAndSort() {
    setState(() {
      List<Product> filtered = List.from(_productList);

      if (_selectedCategory != 'All') {
        filtered = filtered
            .where((product) =>
                product.categories
                    ?.any((cat) => cat.name == _selectedCategory) ==
                true)
            .toList();
      }

      final searchQuery = _searchController.text.toLowerCase().trim();
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((product) =>
                product.name?.toLowerCase().contains(searchQuery) == true ||
                product.description?.toLowerCase().contains(searchQuery) ==
                    true)
            .toList();
      }

      _filteredProductList = filtered;
    });
  }

  static const List<String> _sortOptions = [
    'Popular',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
  ];
}


