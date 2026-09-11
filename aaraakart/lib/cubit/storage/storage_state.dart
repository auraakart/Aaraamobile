import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';

class StorageState {
  final UserDetail? userData;
  final bool? isGuestMode;
  final List<GetAddressResponse> addressData;
  final List<CartItem>? favItems;

  StorageState({
    this.userData,
    this.isGuestMode,
    this.addressData = const [],
    this.favItems,
  });

  StorageState copyWith({
    UserDetail? userData,
    bool? isGuestMode,
    List<GetAddressResponse>? addressData,
    List<CartItem>? favItems,
  }) {
    return StorageState(
      userData: userData ?? this.userData,
      isGuestMode: isGuestMode ?? this.isGuestMode,
      addressData: addressData ?? this.addressData,
      favItems: favItems ?? this.favItems,
    );
  }
}


