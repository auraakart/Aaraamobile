import 'package:aaraa_kart/data/model/mobile_banner_response.dart';

abstract class BannerState {}

class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {
  final bool isLoading;

  BannerLoading({required this.isLoading});
}

class BannerSuccess extends BannerState {
  final List<MobileBanner> banners;

  BannerSuccess({required this.banners});
}

class BannerError extends BannerState {
  final String message;

  BannerError(this.message);
}


