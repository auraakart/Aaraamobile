import 'dart:convert';

import 'package:aaraa_kart/app/utils/shared_preferences.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/cubit/cart/cart_state.dart';
import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(items: []));

  void addAllItems(List<CartItem> items) {
    emit(CartState(items: items));
  }

  void addItem(CartItem newItem, BuildContext context) {
    debugPrint("Adding item to cart: ${newItem.name}");

    final existingIndex = state.items.indexWhere((item) =>
        item.id == newItem.id && item.deliveryDate == newItem.deliveryDate);
    List<CartItem> updatedItems = List<CartItem>.from(state.items);

    if (existingIndex >= 0) {
      final updatedItem = updatedItems[existingIndex]
          .copyWith(quantity: updatedItems[existingIndex].quantity + 1);
      updatedItems[existingIndex] = updatedItem;
    } else {
      updatedItems.add(newItem);
    }

    final totalQuantity =
        updatedItems.fold<int>(0, (sum, item) => sum + item.quantity);

    // final itemText = totalQuantity == 1 ? "item" : "items";

    List<String> jsonList =
        updatedItems.map((item) => jsonEncode(item.toJson())).toList();
    SharedPrefHelper.saveStringList(AppConstants.cartPrefKey, jsonList);
    emit(CartState(items: updatedItems));

    debugPrint(
        "Cart updated → Total items: ${updatedItems.length}, Total quantity: $totalQuantity");
  }

  void addItemQuantity(CartItem newItem, BuildContext context) {
    debugPrint("Adding item to cart: ${newItem.name}");

    final existingIndex = state.items.indexWhere((item) =>
        item.id == newItem.id && item.deliveryDate == newItem.deliveryDate);
    List<CartItem> updatedItems = List<CartItem>.from(state.items);

    if (existingIndex >= 0) {
      final updatedItem = updatedItems[existingIndex].copyWith(
          quantity: updatedItems[existingIndex].quantity + newItem.quantity);
      updatedItems[existingIndex] = updatedItem;
    } else {
      updatedItems.add(newItem);
    }

    final totalQuantity =
        updatedItems.fold<int>(0, (sum, item) => sum + item.quantity);
    // final itemText = totalQuantity == 1 ? "item" : "items";

    List<String> jsonList =
        updatedItems.map((item) => jsonEncode(item.toJson())).toList();
    SharedPrefHelper.saveStringList(AppConstants.cartPrefKey, jsonList);
    emit(CartState(items: updatedItems));

    debugPrint(
        "Cart updated → Total items: ${updatedItems.length}, Total quantity: $totalQuantity");
  }

  void removeItem(String itemId, {String? deliveryDate}) {
    final existingIndex = state.items.indexWhere((item) =>
        deliveryDate != null
            ? (item.id == itemId && item.deliveryDate == deliveryDate)
            : (item.cartKey == itemId || item.id == itemId));

    if (existingIndex >= 0) {
      List<CartItem> updatedItems = List<CartItem>.from(state.items);
      final existingItem = updatedItems[existingIndex];

      if (existingItem.quantity > 1) {
        updatedItems[existingIndex] =
            existingItem.copyWith(quantity: existingItem.quantity - 1);
      } else {
        updatedItems.removeAt(existingIndex);
      }
      List<String> jsonList =
          updatedItems.map((item) => jsonEncode(item.toJson())).toList();

      SharedPrefHelper.saveStringList(AppConstants.cartPrefKey, jsonList);
      emit(CartState(items: updatedItems));
    }
  }

  void clearItem(String itemId, {String? deliveryDate}) {
    state.items.removeWhere((item) =>
        deliveryDate != null
            ? (item.id == itemId && item.deliveryDate == deliveryDate)
            : (item.cartKey == itemId || item.id == itemId));
    List<String> jsonList =
        state.items.map((item) => jsonEncode(item.toJson())).toList();

    SharedPrefHelper.saveStringList(AppConstants.cartPrefKey, jsonList);
    emit(CartState(items: state.items));
  }

  void clearCart() {
    SharedPrefHelper.saveJsonData(AppConstants.cartPrefKey, []);

    emit(CartState(items: []));
  }

  void syncStockFromProducts(List<Product> products) {
    syncStockStatus({
      for (final product in products)
        if (product.id != null) product.id.toString(): product.isOutOfStock,
    });
  }

  void syncStockStatus(Map<String, bool> stockById) {
    if (stockById.isEmpty || state.items.isEmpty) return;

    var changed = false;
    final updatedItems = state.items.map((item) {
      final outOfStock = stockById[item.id];
      if (outOfStock == null || outOfStock == item.isOutOfStock) return item;
      changed = true;
      return item.copyWith(isOutOfStock: outOfStock);
    }).toList();

    if (!changed) return;

    _persist(updatedItems);
    emit(CartState(items: updatedItems));
  }

  void _persist(List<CartItem> items) {
    final jsonList = items.map((item) => jsonEncode(item.toJson())).toList();
    SharedPrefHelper.saveStringList(AppConstants.cartPrefKey, jsonList);
  }
}


