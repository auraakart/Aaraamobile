import 'package:aaraa_kart/cubit/product/product_state.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';
import 'package:aaraa_kart/domain/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;

  ProductCubit(this._repository) : super(ProductInitial());

  List<DeliverySlot> _activeSlots(List<DeliverySlot>? slots) {
    return (slots ?? [])
        .where((slot) => (slot.status?.toLowerCase() ?? 'active') == 'active')
        .toList();
  }

  Future<void> getProducts(pageNumber, totalPages, category) async {
    if (state is ProductLoading) return;
    emit(ProductLoading(isLoading: true));

    try {
      final result = await _repository.fetchProductList(
          totalPages.toString(), pageNumber.toString(), category);

      final newProducts = result.products;

      emit(ProductSuccess(
        products: newProducts ?? [],
        currentPage: result.currentPage.toString(),
        totalPage: result.totalPages.toString(),
        deliverySlots: _activeSlots(result.deliverySlots),
        deliverySchedule: result.deliverySchedule,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void getProductDetails(productId) async {
    if (state is GetProductDetailsLoading) return;
    emit(GetProductDetailsLoading());

    try {
      final result = await _repository.getProductDetails(productId);

      emit(GetProductDetailsSuccess(
        productDetails: result.product,
        deliverySlots: _activeSlots(result.deliverySlots),
        deliverySchedule: result.deliverySchedule,
      ));
    } catch (e) {
      emit(GetProductDetailsError(e.toString()));
    }
  }
}


