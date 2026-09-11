import 'package:dio/dio.dart';
import 'package:aaraa_kart/core/di/injection.dart';
import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/data/model/reverse_geo_code_response.dart';

class GoogleMapRepository {
  Dio dio = getIt<Dio>(instanceName: 'googleMapsDio');

  GoogleMapRepository(this.dio);

  Future<ReverseGeoCodeResponseModel> getReverseGeoCode(
      String latitude, String longitude) async {
    try {
      Map<String, dynamic> payload = {
        "latlng": '$latitude,$longitude',
      };

      final response = await dio.get(GoogleApiConstants.rEVERSE_GEO_CODE,
          queryParameters: payload);

      return ReverseGeoCodeResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to Get Location Details: $e');
    }
  }
}


