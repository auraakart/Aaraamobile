import 'package:dio/dio.dart';
import 'package:aaraa_kart/core/di/injection.dart';
import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/data/model/category_list_response.dart';

class CategoryRepository {
  Dio dio = getIt<Dio>(instanceName: 'farmersVillageDio');

  CategoryRepository(this.dio);
  Future<CategoryListModel> fetchCategoryList() async {
    Map<String, dynamic> payload = {"category": 28};

    try {
      final response =
          await dio.get(ApiConstants.Categories, queryParameters: payload);

      return CategoryListModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}


