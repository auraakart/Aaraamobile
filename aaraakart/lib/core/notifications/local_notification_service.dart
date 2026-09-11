import 'dart:convert';
import 'dart:io';

import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef NotificationTapCallback = void Function(Map<String, dynamic> data);

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  NotificationTapCallback? _onTap;

  int _nextId = 0;

  Future<void> initialize({NotificationTapCallback? onTap}) async {
    if (onTap != null) _onTap = onTap;
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _handleResponse,
    );

    await _createAndroidChannel();
    _initialized = true;
  }

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;

    final brand = BrandConfig.instance.notifications;
    final channel = AndroidNotificationChannel(
      BrandNotifications.channelId,
      brand.channelName,
      description: brand.channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) _onTap?.call(decoded);
    } on FormatException {
      // Payload wasn't ours; nothing to route to.
    }
  }

  Future<void> showFromMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ?? data['title']?.toString() ?? '';
    final body = notification?.body ?? data['body']?.toString() ?? '';
    if (title.isEmpty && body.isEmpty) return;

    final imageUrl = Platform.isIOS
        ? notification?.apple?.imageUrl ?? data['image']?.toString()
        : notification?.android?.imageUrl ?? data['image']?.toString();

    await show(
      title: title,
      body: body,
      imageUrl: imageUrl,
      payload: data,
    );
  }

  Future<void> show({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? payload,
  }) async {
    await initialize();

    final brand = BrandConfig.instance;

    StyleInformation? style;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final path = await _downloadImage(imageUrl);
      if (path != null) {
        style = BigPictureStyleInformation(
          FilePathAndroidBitmap(path),
          contentTitle: title,
          summaryText: body,
        );
      }
    }

    final androidDetails = AndroidNotificationDetails(
      BrandNotifications.channelId,
      brand.notifications.channelName,
      channelDescription: brand.notifications.channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/launcher_icon',
      color: brand.theme.primary,
      styleInformation: style,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    _nextId = (_nextId + 1) % 100000;

    await _plugin.show(
      _nextId,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload == null ? null : jsonEncode(payload),
    );
  }

  Future<String?> _downloadImage(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/notif_${DateTime.now().millisecondsSinceEpoch}',
      );
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}


