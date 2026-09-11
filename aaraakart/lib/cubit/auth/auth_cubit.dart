import 'package:aaraa_kart/app/utils/shared_preferences.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/cubit/auth/auth_state.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/user_create_request.dart';
import 'package:aaraa_kart/domain/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  Future<void> sendOtp(String phoneNumber) async {
    emit(SendOTPLoading(isLoading: true));

    try {
      final result = await _repository.sendOTP(phoneNumber);

      if (result.success == true) {
        emit(SendOTPSuccess(data: result));
      } else {
        emit(SendOTPError(result.message.toString()));
      }
    } catch (e) {
      emit(SendOTPError(e.toString()));
    }
  }

  Future<void> verifyOTP(String phoneNumber, String otp) async {
    emit(VerifyOTPLoading(isLoading: true));

    try {
      final result = await _repository.verifyOTP(phoneNumber, otp);

      if (result.success == true) {
        emit(VerifyOTPSuccess(data: result));
      } else {
        emit(VerifyOTPError(result.message.toString()));
      }
    } catch (e) {
      emit(VerifyOTPError(e.toString()));
    }
  }

  void createCustomer(UserCreateRequest request) async {
    emit(CreateCustomerLoading(isLoading: true));

    try {
      final result = await _repository.createCustomer(request);

      if (result.data != null && result.data!.id != null) {
        emit(CreateCustomerSuccess(data: result.data));
      } else {
        emit(CreateCustomerError(result.error.toString()));
      }
      emit(CreateCustomerLoading(isLoading: false));
    } catch (e) {
      emit(CreateCustomerError(e.toString()));
      emit(CreateCustomerLoading(isLoading: false));
    }
  }

  void fetchCustomer(String customerID) async {
    try {
      final result = await _repository.fetchCustomer(customerID);

      if (result.data != null && result.data!.id != null) {
        emit(FetchCustomerSuccess(data: result.data));
      } else {
        emit(FetchCustomerError(result.error.toString()));
      }
    } catch (e) {
      emit(FetchCustomerError(e.toString()));
      emit(FetchCustomerLoading(isLoading: false));
    }
  }

  void deleteProfileCustomer(String customerID) async {
    emit(DeleteCustomerLoading(isLoading: true));

    try {
      final result = await _repository.deleteProfileCustomer(customerID);

      if (result == true) {
        emit(DeleteCustomerSuccess(data: result));
      } else {
        emit(DeleteCustomerError("Failed"));
      }
      emit(DeleteCustomerLoading(isLoading: false));
    } catch (e) {
      emit(DeleteCustomerError(e.toString()));
      emit(DeleteCustomerLoading(isLoading: false));
    }
  }

  void addAddress(GetAddressResponse addressData) async {
    emit(CreateAddressLoading(isLoading: true));

    try {
      final created = await _repository.createAddress(addressData);

      if (created.id != null) {
        final addresses =
            await _repository.listAddress('${addressData.customerId}');
        await SharedPrefHelper.saveJsonData(
            AppConstants.addressPrefKey, addresses);
        emit(CreateAddressSuccess(data: addresses));
      } else {
        emit(CreateAddressError("Failed to Create Address"));
      }
      emit(CreateAddressLoading(isLoading: false));
    } catch (e) {
      emit(CreateAddressError(e.toString()));
      emit(CreateAddressLoading(isLoading: false));
    }
  }

  void deleteAddress({required String addrID, required String userId}) async {
    emit(DeleteAddressLoading(isLoading: true));

    try {
      await _repository.deleteAddress(addrID: addrID, userId: userId);

      final addresses = await _repository.listAddress(userId);
      await SharedPrefHelper.saveJsonData(
          AppConstants.addressPrefKey, addresses);
      emit(DeleteAddressSuccess(data: addresses));
      emit(DeleteAddressLoading(isLoading: false));
    } catch (e) {
      emit(DeleteAddressError(e.toString()));
      emit(DeleteAddressLoading(isLoading: false));
    }
  }

  void updateAddress({required String addrID, required String userId}) async {
    emit(UpdateAddressLoading(isLoading: true));

    try {
      final updated =
          await _repository.updateAddress(addrID: addrID, userId: userId);

      final addresses = await _repository.listAddress(userId);
      await SharedPrefHelper.saveJsonData(
          AppConstants.addressPrefKey, addresses);
      emit(UpdateAddressSuccess(data: addresses));

      emit(UpdateAddressLoading(isLoading: false));
    } catch (e) {
      emit(UpdateAddressError(e.toString()));
      emit(UpdateAddressLoading(isLoading: false));
    }
  }

  Future<void> listAddress(String userId) async {
    emit(ListAddressLoading(isLoading: true));

    try {
      final addresses = await _repository.listAddress(userId);
      await SharedPrefHelper.saveJsonData(
          AppConstants.addressPrefKey, addresses);
      emit(ListAddressSuccess(data: addresses));
      emit(ListAddressLoading(isLoading: false));
    } catch (e) {
      emit(ListAddressError(e.toString()));
      emit(ListAddressLoading(isLoading: false));
    }
  }

  void reset() => emit(AuthInitial());
}


