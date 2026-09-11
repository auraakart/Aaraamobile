import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class BrandConfig {
  BrandConfig({
    required this.brandId,
    required this.appName,
    required this.bundleId,
    required this.packageName,
    required this.android,
    required this.ios,
    required this.theme,
    required this.maps,
    required this.api,
    required this.payment,
    required this.images,
    required this.content,
    required this.notifications,
  });

  static const String assetPath = 'assets/brand/config.json';

  static late BrandConfig instance;

  static bool _loaded = false;
  static bool get isLoaded => _loaded;

  final String brandId;
  final String appName;
  final String bundleId;
  final String packageName;
  final BrandPlatformVersion android;
  final BrandPlatformVersion ios;

  BrandPlatformVersion get currentPlatformVersion =>
      Platform.isIOS ? ios : android;
  String get version => currentPlatformVersion.version;
  int get buildNumber => currentPlatformVersion.buildNumber;

  final BrandTheme theme;
  final BrandMaps maps;
  final BrandApi api;
  final BrandPayment payment;
  final BrandImages images;
  final BrandContent content;
  final BrandNotifications notifications;

  static Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    instance = BrandConfig.fromJson(json);
    _loaded = true;
  }

  factory BrandConfig.fromJson(Map<String, dynamic> json) {
    return BrandConfig(
      brandId: json['brandId'] as String,
      appName: json['appName'] as String,
      bundleId: json['bundleId'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      android: BrandPlatformVersion.fromJson(_map(json['android'])),
      ios: BrandPlatformVersion.fromJson(_map(json['ios'])),
      theme: BrandTheme.fromJson(_map(json['theme'])),
      maps: BrandMaps.fromJson(_map(json['maps'])),
      api: BrandApi.fromJson(_map(json['api'])),
      payment: BrandPayment.fromJson(_map(json['payment'])),
      images: BrandImages.fromJson(_map(json['images'])),
      content: BrandContent.fromJson(_map(json['content'])),
      notifications: BrandNotifications.fromJson(
        _map(json['notifications']),
        appName: json['appName'] as String? ?? '',
        brandId: json['brandId'] as String? ?? '',
      ),
    );
  }

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map<String, dynamic> ? v : <String, dynamic>{};

  static Map<String, String> _stringMap(dynamic v) => v is Map<String, dynamic>
      ? v.map((k, value) => MapEntry(k, value?.toString() ?? ''))
      : <String, String>{};
}

class BrandPlatformVersion {
  BrandPlatformVersion({required this.version, required this.buildNumber});

  final String version;
  final int buildNumber;

  factory BrandPlatformVersion.fromJson(Map<String, dynamic> json) =>
      BrandPlatformVersion(
        version: json['version'] as String? ?? '1.0.0',
        buildNumber: (json['buildNumber'] as num?)?.toInt() ?? 1,
      );
}

Color hexToColor(String hex, {Color fallback = const Color(0xFF000000)}) {
  var value = hex.trim().replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

class BrandTheme {
  BrandTheme({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.white,
    required this.backgroundBase,
    required this.backgroundSurface,
    required this.backgroundElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.error,
    required this.borderDefault,
    required this.borderDisabled,
    required this.shimmerBaseLight,
    required this.shimmerBaseDark,
    required this.shimmerDragLight,
    required this.shimmerDragDark,
  });

  final Color primary;
  final Color primaryDark;
  final Color secondary;

  final Color white;

  final Color backgroundBase;
  final Color backgroundSurface;
  final Color backgroundElevated;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  final Color error;

  final Color borderDefault;
  final Color borderDisabled;

  final Color shimmerBaseLight;
  final Color shimmerBaseDark;
  final Color shimmerDragLight;
  final Color shimmerDragDark;

  factory BrandTheme.fromJson(Map<String, dynamic> json) {
    Color c(String key, String fallback) =>
        hexToColor((json[key] as String?) ?? fallback);
    return BrandTheme(
      primary: c('primaryColor', '#0E8C17'),
      primaryDark: c('primaryDarkColor', '#0A5C12'),
      secondary: c('secondaryColor', '#FF8C42'),
      white: c('whiteColor', '#FFFFFF'),
      backgroundBase: c('backgroundBaseColor', '#F8F9FA'),
      backgroundSurface: c('backgroundSurfaceColor', '#FFFFFF'),
      backgroundElevated: c('backgroundElevatedColor', '#F6F7F9'),
      textPrimary: c('textPrimaryColor', '#1F1F1F'),
      textSecondary: c('textSecondaryColor', '#606060'),
      textTertiary: c('textTertiaryColor', '#8C8C8C'),
      textDisabled: c('textDisabledColor', '#B0B0B0'),
      error: c('errorColor', '#E74C3C'),
      borderDefault: c('borderDefaultColor', '#E5E7EB'),
      borderDisabled: c('borderDisabledColor', '#EEEEEE'),
      shimmerBaseLight: c('shimmerBaseLightColor', '#F0F0F0'),
      shimmerBaseDark: c('shimmerBaseDarkColor', '#E0E0E0'),
      shimmerDragLight: c('shimmerDragLightColor', '#FAFAFA'),
      shimmerDragDark: c('shimmerDragDarkColor', '#F5F5F5'),
    );
  }
}

class BrandMaps {
  BrandMaps({required this.apiKey, required this.nativeApiKey});

  final String apiKey;

  final String nativeApiKey;

  factory BrandMaps.fromJson(Map<String, dynamic> json) => BrandMaps(
        apiKey: json['apiKey'] as String? ?? '',
        nativeApiKey: json['nativeApiKey'] as String? ?? '',
      );
}

class BrandApi {
  BrandApi({
    required this.baseUrl,
    required this.wooConsumerKey,
    required this.wooConsumerSecret,
    required this.walletConsumerKey,
    required this.walletConsumerSecret,
  });

  final String baseUrl;
  final String wooConsumerKey;
  final String wooConsumerSecret;
  final String walletConsumerKey;
  final String walletConsumerSecret;

  factory BrandApi.fromJson(Map<String, dynamic> json) => BrandApi(
        baseUrl: json['baseUrl'] as String? ?? '',
        wooConsumerKey: json['wooConsumerKey'] as String? ?? '',
        wooConsumerSecret: json['wooConsumerSecret'] as String? ?? '',
        walletConsumerKey: json['walletConsumerKey'] as String? ?? '',
        walletConsumerSecret: json['walletConsumerSecret'] as String? ?? '',
      );
}

class BrandPayment {
  BrandPayment({
    required this.merchantId,
    required this.baseUrl,
    required this.paytmMid,
    required this.paytmMerchantKey,
    required this.paytmWebsite,
    required this.paytmIndustryType,
    required this.paytmChannelIdWeb,
    required this.paytmChannelIdApp,
    required this.paytmIsStaging,
    required this.paytmInitiateTransactionUrl,
    required this.paytmResponseUrl,
    required this.paytmVerifyTransactionUrl,
  });

  final String merchantId;
  final String baseUrl;

  final String paytmMid;
  final String paytmMerchantKey;
  final String paytmWebsite;
  final String paytmIndustryType;
  final String paytmChannelIdWeb;
  final String paytmChannelIdApp;
  final bool paytmIsStaging;

  final String paytmInitiateTransactionUrl;
  final String paytmResponseUrl;
  final String paytmVerifyTransactionUrl;

  factory BrandPayment.fromJson(
    Map<String, dynamic> json,
  ) =>
      BrandPayment(
        merchantId: json['merchantId'] as String? ?? '',
        baseUrl: json['baseUrl'] as String? ?? '',
        paytmMid: json['paytmMid'] as String? ?? '',
        paytmMerchantKey: json['paytmMerchantKey'] as String? ?? '',
        paytmWebsite: json['paytmWebsite'] as String? ?? 'DEFAULT',
        paytmIndustryType: json['paytmIndustryType'] as String? ?? 'Retail92',
        paytmChannelIdWeb: json['paytmChannelIdWeb'] as String? ?? 'WEB',
        paytmChannelIdApp: json['paytmChannelIdApp'] as String? ?? 'WA',
        paytmIsStaging: json['paytmIsStaging'] as bool? ?? false,
        paytmInitiateTransactionUrl:
            json['paytmInitiateTransactionUrl'] as String? ?? '',
        paytmResponseUrl: json['paytmResponseUrl'] as String? ?? '',
        paytmVerifyTransactionUrl:
            json['paytmVerifyTransactionUrl'] as String? ?? '',
      );

  String get requestHandlerUrl => '$baseUrl/ccavRequestHandler.php';

  String get responseUrl => '$baseUrl/payment_response.php';

  String get cancelUrl => '$baseUrl/payment_cancel.php';

  String get paytmGatewayBaseUrl => paytmIsStaging
      ? 'https://securestage.paytmpayments.com'
      : 'https://secure.paytmpayments.com';

  String paytmShowPaymentPageUrl(String orderId) =>
      '$paytmGatewayBaseUrl/theia/api/v1/showPaymentPage'
      '?mid=$paytmMid&orderId=$orderId';
}

class BrandImages {
  BrandImages({
    required this.logo,
    required this.splash,
    required this.icon,
    required this.banner,
    required this.successLottie,
    required this.defaultProduct,
  });

  final String logo;
  final String splash;
  final String icon;
  final String banner;
  final String successLottie;

  final String defaultProduct;

  factory BrandImages.fromJson(Map<String, dynamic> json) => BrandImages(
        logo: json['logo'] as String? ?? 'assets/brand/logo.png',
        splash: json['splash'] as String? ?? 'assets/brand/splash.png',
        icon: json['icon'] as String? ?? 'assets/brand/icon.png',
        banner: json['banner'] as String? ?? 'assets/brand/banner.jpg',
        successLottie:
            json['successLottie'] as String? ?? 'assets/brand/success.json',
        defaultProduct: json['defaultProduct'] as String? ?? '',
      );

  String categoryIcon(String category) =>
      'assets/brand/icons/$category-icon.svg';
}

class BrandContent {
  BrandContent(
      {required this.welcomeTitle,
      required this.welcomeDescription,
      required this.phoneCountryCode,
      required this.promoBanners,
      required this.termsAndConditionsUrl,
      required this.privacyPolicyUrl,
      required this.faqUrl,
      required this.whatsappNumber,
      required this.supportMail,
      required this.tagline,
      required this.officeAddress});

  final String welcomeTitle;
  final String welcomeDescription;
  final String phoneCountryCode;
  final List<String> promoBanners;
  final String termsAndConditionsUrl;
  final String privacyPolicyUrl;
  final String faqUrl;
  final String whatsappNumber;
  final String supportMail;

  final String tagline;
  final String officeAddress;

  factory BrandContent.fromJson(Map<String, dynamic> json) => BrandContent(
        welcomeTitle: json['welcomeTitle'] as String? ?? '',
        welcomeDescription: json['welcomeDescription'] as String? ?? '',
        phoneCountryCode: json['phoneCountryCode'] as String? ?? '+91',
        promoBanners: (json['promoBanners'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],
        termsAndConditionsUrl: json['termsAndConditionsUrl'] as String? ?? '',
        privacyPolicyUrl: json['privacyPolicyUrl'] as String? ?? '',
        faqUrl: json['faqUrl'] as String? ?? '',
        whatsappNumber: json['whatsappNumber'] as String? ?? '',
        supportMail: json['supportMail'] as String? ?? '',
        tagline: json['tagline'] as String? ?? '',
        officeAddress: json['officeAddress'] as String? ?? '',
      );
}

class BrandNotifications {
  BrandNotifications({
    required this.channelName,
    required this.channelDescription,
    required this.topics,
    required this.guestTopic,
    required this.userTopic,
    required this.inAppMessagingEnabled,
  });

  static const String channelId = 'high_importance_channel';

  final String channelName;
  final String channelDescription;

  final List<String> topics;

  final String guestTopic;
  final String userTopic;

  final bool inAppMessagingEnabled;

  factory BrandNotifications.fromJson(
    Map<String, dynamic> json, {
    required String appName,
    required String brandId,
  }) {
    final topics = (json['topics'] as List?)
        ?.map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();

    return BrandNotifications(
      channelName: json['channelName'] as String? ?? '$appName Updates',
      channelDescription: json['channelDescription'] as String? ??
          'Order updates, delivery alerts and offers from $appName',
      topics:
          topics == null || topics.isEmpty ? <String>['all-$brandId'] : topics,
      guestTopic: json['guestTopic'] as String? ?? 'guests-$brandId',
      userTopic: json['userTopic'] as String? ?? 'users-$brandId',
      inAppMessagingEnabled: json['inAppMessaging'] as bool? ?? true,
    );
  }
}

class BrandFeatures {
  BrandFeatures(this._flags);

  final Map<String, bool> _flags;

  bool isEnabled(String key) => _flags[key] ?? false;

  bool get chat => isEnabled('chat');
  bool get delivery => isEnabled('delivery');
  bool get loyalty => isEnabled('loyalty');

  factory BrandFeatures.fromJson(Map<String, dynamic> json) => BrandFeatures(
        json.map((k, v) => MapEntry(k, v == true)),
      );
}
