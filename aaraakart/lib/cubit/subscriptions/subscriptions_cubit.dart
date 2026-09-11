import 'package:aaraa_kart/cubit/subscriptions/subscriptions_state.dart';
import 'package:aaraa_kart/data/model/create_subscription_request.dart';
import 'package:aaraa_kart/data/model/update_subscription_request.dart';
import 'package:aaraa_kart/domain/subscriptions_repository.dart';
import 'package:aaraa_kart/presentation/subscriptions/subscription_cutoff_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionsCubit extends Cubit<SubscriptionState> {
  final SubscriptionsRepository _repository;

  SubscriptionsCubit(this._repository) : super(SubscriptionInitial());

  Future<void> getSubscriptions(customerID) async {
    if (state is SubscriptionLoading) return;
    emit(SubscriptionLoading(isLoading: true));

    try {
      final result = await _repository.getSubscriptios(customerID);

      // [DEBUG LOG - state/provider update]
      // ignore: avoid_print
      print('=== [DEBUG STATE] SubscriptionsCubit emitting SubscriptionSuccess ===');
      for (final s in result) {
        // ignore: avoid_print
        print('State Sub ID: ${s.id}, status: ${s.status}, nextPaymentDateGmt: ${s.nextPaymentDateGmt}');
      }

      emit(SubscriptionSuccess(subscriptions: result));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  void getSubscriptionVariations(productID, plan) async {
    if (state is GetSubscriptionVariationLoading) return;

    emit(GetSubscriptionVariationLoading(isLoading: true));

    try {
      final variationIDresult =
          await _repository.getSubscriptionVariatonsID(productID, plan);
      final result = await _repository.getSubscriptionVariatons(
          productID, variationIDresult);

      emit(GetSubscriptionVariationSuccess(variationDetails: result));
      validateCreateSubscriptionButton(true);
    } catch (e) {
      emit(GetSubscriptionVariationError(e.toString()));
      validateCreateSubscriptionButton(false);
    }
  }

  void createSubscription(CreateSubscriptionRequestModel request) async {
    if (state is CreateSubscriptionLoading) return;
    emit(CreateSubscriptionLoading(isLoading: true));

    try {
      final result = await _repository.createSubscription(request);

      emit(CreateSubscriptionSuccess(
        subResponse: result,
      ));
    } catch (e) {
      emit(CreateSubscriptionError(e.toString()));
    }
  }

  void updateSubscription(
      UpdateSubscriptionRequest request, String orderID) async {
    if (state is SubscriptionUpdateLoading) return;
    emit(SubscriptionUpdateLoading(isLoading: true));

    try {
      final result = await _repository.updateSubscription(orderID, request);

      emit(SubscriptionUpdateSuccess(
        subscriptionResponse: result,
      ));
    } catch (e) {
      emit(SubscriptionUpdateError(e.toString()));
    }
  }

  void pauseSubscription({
    required String subscriptionId,
    required String customerId,
    required dynamic pauseDates,
    String pauseType = "temporary",
  }) async {
    if (SubscriptionCutoffHelper.isPauseRestricted()) {
      emit(SubscriptionUpdateError(SubscriptionCutoffHelper.cutoffMessage));
      return;
    }
    if (state is SubscriptionUpdateLoading) return;
    emit(SubscriptionUpdateLoading(isLoading: true));

    try {
      await _repository.pauseSubscription(
        subscriptionId: subscriptionId,
        customerId: customerId,
        pauseDates: pauseDates,
        pauseType: pauseType,
      );

      emit(SubscriptionUpdateSuccess(subscriptionResponse: null));
    } catch (e) {
      emit(SubscriptionUpdateError(e.toString()));
    }
  }

  void resumeSubscription({
    required String subscriptionId,
    required String customerId,
    String? billingPeriod,
    dynamic billingInterval,
    dynamic startDate,
    dynamic currentNextPaymentDate,
  }) async {
    if (state is SubscriptionUpdateLoading) return;
    emit(SubscriptionUpdateLoading(isLoading: true));

    try {
      await _repository.resumeSubscription(
        subscriptionId: subscriptionId,
        customerId: customerId,
        billingPeriod: billingPeriod,
        billingInterval: billingInterval,
        startDate: startDate,
        currentNextPaymentDate: currentNextPaymentDate,
      );

      emit(SubscriptionUpdateSuccess(subscriptionResponse: null));
    } catch (e) {
      emit(SubscriptionUpdateError(e.toString()));
    }
  }

  validateCreateSubscriptionButton(bool isValid) {
    emit(ValidateCreateSubState(isValid: isValid));
  }

  void reset() => emit(SubscriptionInitial());
}


