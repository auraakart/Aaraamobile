import 'package:aaraa_kart/core/di/injection.dart';
import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';
import 'package:dio/dio.dart';

class ProductRepository {
  Dio dio = getIt<Dio>(instanceName: 'farmersVillageDio');

  ProductRepository(this.dio);

  Future<ProductListModel> fetchProductList(
      String perPage, String pageNumber, String? category) async {
    try {
      Map<String, dynamic> payload = {
        "per_page": perPage,
        "page": pageNumber,
        "status": "publish"
        // "type": "grouped"
      };

      final response =
          await dio.get(ApiConstants.Products, queryParameters: payload);

      return ProductListModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<ProductListModel> getProductDetails(String productID) async {
    try {
      final response = await dio.get('${ApiConstants.Products}/$productID');

      return ProductListModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get product details: $e');
    }
  }
}


