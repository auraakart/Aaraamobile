import 'package:dio/dio.dart';
import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/data/model/mobile_banner_response.dart';

class BannerRepository {
  Dio dio;

  BannerRepository(this.dio);

  Future<MobileBannerListModel> fetchMobileBanners() async {
    try {
      final response = await dio.get(ApiConstants.MobileBanners);

      return MobileBannerListModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load banners: $e');
    }
  }
}


