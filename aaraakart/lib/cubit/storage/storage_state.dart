import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';

const Object _unsetStorageValue = Object();

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
    Object? userData = _unsetStorageValue,
    Object? isGuestMode = _unsetStorageValue,
    List<GetAddressResponse>? addressData,
    List<CartItem>? favItems,
  }) {
    return StorageState(
      userData: identical(userData, _unsetStorageValue)
          ? this.userData
          : userData as UserDetail?,
      isGuestMode: identical(isGuestMode, _unsetStorageValue)
          ? this.isGuestMode
          : isGuestMode as bool?,
      addressData: addressData ?? this.addressData,
      favItems: favItems ?? this.favItems,
    );
  }
}
