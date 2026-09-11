import 'package:aaraa_kart/data/model/create_subscription_response.dart';
import 'package:aaraa_kart/data/model/get_customer_subs.dart';
import 'package:aaraa_kart/data/model/order_create_response.dart';
import 'package:aaraa_kart/data/model/product_details_response.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {
  final bool isLoading;
  SubscriptionLoading({this.isLoading = true});
}

class SubscriptionSuccess extends SubscriptionState {
  final List<GetCustomerSubscriptionsResponseModel> subscriptions;

  SubscriptionSuccess({
    required this.subscriptions,
  });
}

class SubscriptionError extends SubscriptionState {
  final String message;

  SubscriptionError(this.message);
}

class GetSubscriptionVariationLoading extends SubscriptionState {
  final bool isLoading;
  GetSubscriptionVariationLoading({this.isLoading = true});
}

class GetSubscriptionVariationSuccess extends SubscriptionState {
  final GetProductDetaillsResponseModel variationDetails;

  GetSubscriptionVariationSuccess({
    required this.variationDetails,
  });
}

class GetSubscriptionVariationError extends SubscriptionState {
  final String message;

  GetSubscriptionVariationError(this.message);
}

class ValidateCreateSubState extends SubscriptionState {
  bool isValid = false;
  ValidateCreateSubState({required this.isValid});
  List<Object?> get props => [isValid];
}

class CreateSubscriptionLoading extends SubscriptionState {
  final bool isLoading;
  CreateSubscriptionLoading({this.isLoading = true});
}

class CreateSubscriptionSuccess extends SubscriptionState {
  final CreateSubscriptionResponseModel subResponse;

  CreateSubscriptionSuccess({
    required this.subResponse,
  });
}

class CreateSubscriptionError extends SubscriptionState {
  final String message;

  CreateSubscriptionError(this.message);
}

class SubscriptionUpdateLoading extends SubscriptionState {
  final bool isLoading;
  SubscriptionUpdateLoading({this.isLoading = true});
}

class SubscriptionUpdateSuccess extends SubscriptionState {
  final OrderCreateResponseModel? subscriptionResponse;

  SubscriptionUpdateSuccess({
    required this.subscriptionResponse,
  });
}

class SubscriptionUpdateError extends SubscriptionState {
  final String message;

  SubscriptionUpdateError(this.message);
}


