import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/banner/banner_cubit.dart';
import 'package:aaraa_kart/cubit/banner/banner_state.dart';
import 'package:aaraa_kart/presentation/common/my_app_shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromotionalBanner extends StatefulWidget {
  const PromotionalBanner({super.key});

  @override
  State<PromotionalBanner> createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerCubit, BannerState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is BannerLoading || state is BannerInitial) {
          return MyAppShimmer(
            isLoading: true,
            child: Container(
              height: 150.h,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          );
        }

        if (state is! BannerSuccess || state.banners.isEmpty) {
          return const SizedBox.shrink();
        }

        final banners = state.banners;

        return CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: banners.length,
          itemBuilder: (context, index, realIndex) {
            return PromotionalBannerItem(
              imageUrl: banners[index].image ?? '',
            );
          },
          options: CarouselOptions(
            height: 150.h,
            viewportFraction: 1,
            enlargeCenterPage: true,
            enableInfiniteScroll: banners.length > 1,
            autoPlay: banners.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {},
          ),
        );
      },
    );
  }
}

class PromotionalBannerItem extends StatelessWidget {
  final String imageUrl;

  const PromotionalBannerItem({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        height: 180.h,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image.network(
            imageUrl,
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return MyAppShimmer(
                isLoading: true,
                child: Container(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.brandPrimary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textSecondary.withOpacity(0.3),
                  size: 20.r,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


