import 'dart:io';

import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/core/notifications/local_notification_service.dart';
import 'package:aaraa_kart/core/notifications/notification_navigator.dart';
import 'package:aaraa_kart/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) return;

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await BrandConfig.load();
  await LocalNotificationService.instance.initialize();
  await LocalNotificationService.instance.showFromMessage(message);
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const String _tokenPrefKey = 'FCM_DEVICE_TOKEN';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  ValueChanged<String>? onToken;

  String? _token;
  String? get token => _token;

  bool _ready = false;
  bool? _pendingIsGuest;
  bool? _appliedIsGuest;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await LocalNotificationService.instance.initialize(
      onTap: NotificationNavigator.handle,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);
    _messaging.onTokenRefresh.listen(_publishToken);
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _debugLog('Notifications denied; skipping token and topics.');
      return;
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _resolveToken();
    await _subscribeToBrandTopics();

    _ready = true;
    final pending = _pendingIsGuest;
    if (pending != null) {
      _pendingIsGuest = null;
      await syncAudienceTopics(isGuest: pending);
    }

    await _handleInitialMessage();
  }

  Future<void> syncAudienceTopics({required bool isGuest}) async {
    if (!_ready) {
      _pendingIsGuest = isGuest;
      return;
    }
    if (_appliedIsGuest == isGuest) return;

    final brand = BrandConfig.instance.notifications;
    final join = isGuest ? brand.guestTopic : brand.userTopic;
    final leave = isGuest ? brand.userTopic : brand.guestTopic;

    try {
      await _messaging.subscribeToTopic(join);
      await _messaging.unsubscribeFromTopic(leave);
      _appliedIsGuest = isGuest;
    } catch (e) {
      _debugLog('Audience topic sync failed.');
    }
  }

  Future<void> _resolveToken() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken;
        for (var attempt = 0; attempt < 10 && apnsToken == null; attempt++) {
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken == null) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
        if (apnsToken == null) {
          _debugLog('APNS token unavailable; skipping FCM token fetch.');
          return;
        }
      }

      final token = await _messaging.getToken();
      if (token != null) await _publishToken(token);
    } catch (e) {
      _debugLog('Token resolution failed.');
    }
  }

  Future<void> _publishToken(String token) async {
    _token = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenPrefKey, token);
    } catch (e) {
      _debugLog('Could not persist notification token.');
    }
    onToken?.call(token);
  }

  Future<void> _subscribeToBrandTopics() async {
    for (final topic in BrandConfig.instance.notifications.topics) {
      try {
        await _messaging.subscribeToTopic(topic);
      } catch (e) {
        _debugLog('Failed to subscribe to a configured notification topic.');
      }
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    _debugLog('Foreground notification received.');

    if (Platform.isIOS && message.notification != null) return;
    LocalNotificationService.instance.showFromMessage(message);
  }

  void _onNotificationTap(RemoteMessage message) {
    NotificationNavigator.handle(message.data);
  }

  Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message == null) return;

    NotificationNavigator.handle(message.data);
    NotificationNavigator.flushPending();
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('FCM: $message');
    }
  }
}
