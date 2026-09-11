import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<String?> resolveCheckoutUserAgent() async {
  try {
    final defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();

    if (Platform.isAndroid) {
      return defaultUserAgent
          .replaceAll(RegExp(r';\s*wv\b'), '')
          .replaceAll(RegExp(r'\s*Build/[^;)]+'), '')
          .replaceAll(RegExp(r'\s*Version/\d+(\.\d+)*'), '')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
    }

    return defaultUserAgent.trim();
  } catch (e) {
    debugPrint('Checkout webview: could not read the default user-agent ($e)');
    return null;
  }
}

InAppWebViewGroupOptions buildCheckoutWebViewOptions({String? userAgent}) {
  return InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      javaScriptEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,
      userAgent: userAgent ?? '',
    ),
    android: AndroidInAppWebViewOptions(
      useWideViewPort: false,
      useHybridComposition: true,
      loadWithOverviewMode: true,
      domStorageEnabled: true,
      databaseEnabled: true,
      thirdPartyCookiesEnabled: true,
      mixedContentMode:
          AndroidMixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
      enableViewportScale: true,
      ignoresViewportScaleLimits: true,
    ),
  );
}


