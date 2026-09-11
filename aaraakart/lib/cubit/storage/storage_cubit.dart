import 'dart:async';

import 'package:aaraa_kart/app/utils/shared_preferences.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/core/notifications/push_notification_service.dart';
import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StorageCubit extends Cubit<StorageState> {
  StorageCubit() : super(StorageState());

  void setUserData(UserDetail? userData) {
    try {
      SharedPrefHelper.saveJsonData(
          AppConstants.userPrefKey, userData?.toJson());
      emit(state.copyWith(userData: userData));
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  void setIsGuestMode(bool? isGuestMode) {
    try {
      SharedPrefHelper.saveJsonData(
          AppConstants.guestPrefKey, {"guestMode": isGuestMode});
      emit(state.copyWith(isGuestMode: isGuestMode));
      unawaited(
        PushNotificationService.instance
            .syncAudienceTopics(isGuest: isGuestMode != false),
      );
    } catch (e) {
      print('Error saving guest mode: $e');
    }
  }

  UserDetail? get userData => state.userData;
  bool? get isGuestMode => state.isGuestMode;

  void removeAddress() {
    SharedPrefHelper.removeData(AppConstants.addressPrefKey);
    emit(state.copyWith(addressData: []));
  }

  Future<void> getAddress() async {
    final List<dynamic>? addressList =
        await SharedPrefHelper.getJsonData(AppConstants.addressPrefKey);

    if (addressList != null && addressList.isNotEmpty) {
      final parsedAddresses =
          addressList.map((item) => GetAddressResponse.fromJson(item)).toList();

      emit(state.copyWith(addressData: parsedAddresses));
    } else {
      emit(state.copyWith(addressData: []));
    }
  }
}


