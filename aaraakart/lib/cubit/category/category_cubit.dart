import 'package:aaraa_kart/cubit/category/category_state.dart';
import 'package:aaraa_kart/domain/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(CategoryInitial());

  Future<void> getCategoryList() async {
    if (state is CategoryLoading) return;
    emit(CategoryLoading(isLoading: true));

    try {
      final result = await _repository.fetchCategoryList();
      if (result.products!.isEmpty) {
        emit(CategoryError('No categories found'));
        return;
      }
      emit(CategorySuccess(
        categorys: result.products!
            .where((item) => item.id != 25 && item.id != 80 && item.id != 26)
            .toList(),
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}


