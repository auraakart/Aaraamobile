import 'dart:convert';

import 'package:aaraa_kart/app/utils/post_login_loader.dart';
import 'package:aaraa_kart/app/utils/shared_preferences.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/auth/auth_state.dart';
import 'package:aaraa_kart/cubit/banner/banner_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/category/category_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitialized = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) checkLoginStatus();
    });
  }

  Future<void> checkLoginStatus() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _loadCatalog();
    await _loadCartItems();

    final userData =
        await SharedPrefHelper.getJsonData(AppConstants.userPrefKey);
    final guestData =
        await SharedPrefHelper.getJsonData(AppConstants.guestPrefKey);

    if (guestData is Map<String, dynamic> && guestData["guestMode"] == true) {
      context.read<StorageCubit>().setIsGuestMode(true);
      _navigate('/bottom-bar');
      return;
    }

    if (userData is Map<String, dynamic>) {
      final userModel = UserDetail.fromJson(userData);
      final customerId = userData['customerID'];

      context.read<StorageCubit>().setUserData(userModel);
      context.read<StorageCubit>().setIsGuestMode(false);

      if (customerId != null && customerId.toString().isNotEmpty) {
        context.read<AuthCubit>().fetchCustomer(customerId);
        return;
      }
    }

    _navigate('/login');
  }

  Future<void> _loadCatalog() {
    return Future.wait([
      context.read<CategoryCubit>().getCategoryList(),
      context.read<ProductCubit>().getProducts("1", "20", null),
      context.read<BannerCubit>().getMobileBanners(),
    ]);
  }

  Future<void> _loadCartItems() async {
    try {
      final stringList =
          await SharedPrefHelper.getStringList(AppConstants.cartPrefKey);

      if (stringList.isNotEmpty && mounted) {
        final cartItems = stringList
            .map((item) => CartItem.fromJson(jsonDecode(item)))
            .toList();

        if (cartItems.isNotEmpty) {
          context.read<CartCubit>().addAllItems(cartItems);
        }
      }
    } catch (_) {}
  }

  void _navigate(String route) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (_hasNavigated) return;

        if (state is FetchCustomerSuccess) {
          final customer = state.data;
          final storedUser = context.read<StorageCubit>().userData;

          final userDetail = UserDetail(
            customerID: customer?.id.toString() ?? storedUser?.customerID,
            phoneNumber: storedUser?.phoneNumber,
            isVerified: true,
            name: customer?.firstName ?? storedUser?.name,
            email: customer?.email ?? storedUser?.email,
          );

          context.read<StorageCubit>().setUserData(userDetail);
          context.read<StorageCubit>().setIsGuestMode(false);

          final customerId =
              customer?.id.toString() ?? storedUser?.customerID ?? "";

          await loadUserAppData(context, customerId);

          if (!mounted) return;
          _navigate('/bottom-bar');
        } else if (state is FetchCustomerError) {
          context.read<CartCubit>().clearCart();
          context.read<StorageCubit>().removeAddress();

          _navigate('/login');
        }
      },
      child: Scaffold(
        body: Center(
          child: Image.asset(
            AppAssets.logoTFV,
            height: 80.r,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}


