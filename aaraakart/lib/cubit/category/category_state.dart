import 'package:aaraa_kart/data/model/category_list_response.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {
  final bool isLoading;
  CategoryLoading({this.isLoading = true});
}

class CategorySuccess extends CategoryState {
  final List<CategoryProduct>? categorys;

  CategorySuccess({
    required this.categorys,
  });
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);
}


