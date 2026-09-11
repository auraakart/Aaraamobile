import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/send_otp_response.dart';
import 'package:aaraa_kart/data/model/user_create_response.dart';
import 'package:aaraa_kart/data/model/verify_otp_response.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthChecking extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class SendOTPLoading extends AuthState {
  final bool isLoading;

  SendOTPLoading({required this.isLoading});
}

class SendOTPSuccess extends AuthState {
  final SendOtpResponse data;

  SendOTPSuccess({required this.data});
}

class SendOTPError extends AuthState {
  final String message;

  SendOTPError(this.message);
}

class VerifyOTPLoading extends AuthState {
  final bool isLoading;

  VerifyOTPLoading({required this.isLoading});
}

class VerifyOTPSuccess extends AuthState {
  final VerifyOtpResponse data;

  VerifyOTPSuccess({required this.data});
}

class VerifyOTPError extends AuthState {
  final String message;

  VerifyOTPError(this.message);
}

class CreateCustomerLoading extends AuthState {
  final bool isLoading;

  CreateCustomerLoading({required this.isLoading});
}

class CreateCustomerSuccess extends AuthState {
  final UserCreateResponseModel? data;

  CreateCustomerSuccess({required this.data});
}

class CreateCustomerError extends AuthState {
  final String message;

  CreateCustomerError(this.message);
}

class FetchCustomerLoading extends AuthState {
  final bool isLoading;

  FetchCustomerLoading({required this.isLoading});
}

class FetchCustomerSuccess extends AuthState {
  final UserCreateResponseModel? data;

  FetchCustomerSuccess({required this.data});
}

class FetchCustomerError extends AuthState {
  final String message;

  FetchCustomerError(this.message);
}

class CreateAddressLoading extends AuthState {
  final bool isLoading;

  CreateAddressLoading({required this.isLoading});
}

class CreateAddressSuccess extends AuthState {
  final List<GetAddressResponse>? data;

  CreateAddressSuccess({required this.data});
}

class CreateAddressError extends AuthState {
  final String message;

  CreateAddressError(this.message);
}

class DeleteCustomerLoading extends AuthState {
  final bool isLoading;

  DeleteCustomerLoading({required this.isLoading});
}

class DeleteCustomerSuccess extends AuthState {
  final bool? data;

  DeleteCustomerSuccess({required this.data});
}

class DeleteCustomerError extends AuthState {
  final String message;

  DeleteCustomerError(this.message);
}

class UpdateAddressLoading extends AuthState {
  final bool isLoading;

  UpdateAddressLoading({required this.isLoading});
}

class UpdateAddressSuccess extends AuthState {
  final List<GetAddressResponse>? data;

  UpdateAddressSuccess({required this.data});
}

class UpdateAddressError extends AuthState {
  final String message;

  UpdateAddressError(this.message);
}

class DeleteAddressLoading extends AuthState {
  final bool isLoading;

  DeleteAddressLoading({required this.isLoading});
}

class DeleteAddressSuccess extends AuthState {
  final List<GetAddressResponse>? data;

  DeleteAddressSuccess({required this.data});
}

class DeleteAddressError extends AuthState {
  final String message;

  DeleteAddressError(this.message);
}

class ListAddressLoading extends AuthState {
  final bool isLoading;

  ListAddressLoading({required this.isLoading});
}

class ListAddressSuccess extends AuthState {
  final List<GetAddressResponse>? data;

  ListAddressSuccess({required this.data});
}

class ListAddressError extends AuthState {
  final String message;

  ListAddressError(this.message);
}


