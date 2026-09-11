import 'dart:async';

import 'package:aaraa_kart/app/utils/secure_storage.dart';
import 'package:aaraa_kart/app/utils/shared_preferences.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/core/notifications/push_notification_service.dart';
import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StorageCubit extends Cubit<StorageState> {
  StorageCubit() : super(StorageState());

  Future<void> setUserData(UserDetail? userData) async {
    emit(state.copyWith(userData: userData));

    try {
      if (userData == null) {
        await SecureStorageHelper.removeData(AppConstants.userPrefKey);
      } else {
        await SecureStorageHelper.saveJsonData(
          AppConstants.userPrefKey,
          userData.toJson(),
        );
      }

      await SharedPrefHelper.removeData(AppConstants.userPrefKey);
    } catch (_) {
      if (kDebugMode) {
        debugPrint('Unable to persist user identity data securely.');
      }
      rethrow;
    }
  }

  Future<void> setIsGuestMode(bool? isGuestMode) async {
    emit(state.copyWith(isGuestMode: isGuestMode));

    try {
      await SharedPrefHelper.saveJsonData(
        AppConstants.guestPrefKey,
        {'guestMode': isGuestMode},
      );
      unawaited(
        PushNotificationService.instance
            .syncAudienceTopics(isGuest: isGuestMode != false),
      );
    } catch (_) {
      if (kDebugMode) {
        debugPrint('Unable to persist guest mode.');
      }
      rethrow;
    }
  }

  UserDetail? get userData => state.userData;
  bool? get isGuestMode => state.isGuestMode;

  Future<void> removeAddress() async {
    emit(state.copyWith(addressData: []));
    await SecureStorageHelper.removeData(AppConstants.addressPrefKey);
    await SharedPrefHelper.removeData(AppConstants.addressPrefKey);
  }

  Future<void> getAddress() async {
    dynamic stored =
        await SecureStorageHelper.getJsonData(AppConstants.addressPrefKey);

    if (stored is! List) {
      final legacy =
          await SharedPrefHelper.getJsonData(AppConstants.addressPrefKey);
      if (legacy is List) {
        stored = legacy;
        await SecureStorageHelper.saveJsonData(
          AppConstants.addressPrefKey,
          legacy,
        );
        await SharedPrefHelper.removeData(AppConstants.addressPrefKey);
      }
    }

    if (stored is List && stored.isNotEmpty) {
      final parsedAddresses = stored
          .map((item) => GetAddressResponse.fromJson(item))
          .toList();
      emit(state.copyWith(addressData: parsedAddresses));
    } else {
      emit(state.copyWith(addressData: []));
    }
  }
}
