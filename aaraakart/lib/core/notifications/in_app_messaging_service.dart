// import 'package:aaraa_kart/core/config/brand_config.dart';
// import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
// import 'package:flutter/widgets.dart';

// class InAppMessagingService {
//   InAppMessagingService._();

//   static final InAppMessagingService instance = InAppMessagingService._();

//   final FirebaseInAppMessaging _fiam = FirebaseInAppMessaging.instance;

//   bool _suppressedForFlow = false;

//   bool get isEnabledForBrand =>
//       BrandConfig.instance.notifications.inAppMessagingEnabled;

//   Future<void> initialize() async {
//     try {
//       await _fiam.setMessagesSuppressed(!isEnabledForBrand);
//     } catch (e) {
//       debugPrint('FIAM: initialization failed: $e');
//     }
//   }

//   Future<void> triggerEvent(String eventName) async {
//     if (!isEnabledForBrand) return;
//     try {
//       await _fiam.triggerEvent(eventName);
//     } catch (e) {
//       debugPrint('FIAM: trigger "$eventName" failed: $e');
//     }
//   }

//   Future<void> setSuppressedForFlow(bool suppressed) async {
//     if (_suppressedForFlow == suppressed) return;
//     _suppressedForFlow = suppressed;

//     try {
//       await _fiam.setMessagesSuppressed(suppressed || !isEnabledForBrand);
//     } catch (e) {
//       debugPrint('FIAM: suppression toggle failed: $e');
//     }
//   }
// }


