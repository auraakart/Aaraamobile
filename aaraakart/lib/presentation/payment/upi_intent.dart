import 'dart:io' show Platform;

import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

const Set<String> kUpiAppSchemes = {
  'upi',
  'paytm',
  'paytmmp',
  'phonepe',
  'tez',
  'gpay',
  'bhim',
  'credpay',
  'mobikwik',
  'freecharge',
  'amazonpay',
  'myairtelupi',
  'payzapp',
  'navi',
  'jupiter',
  'omnicard',
  'kiwi',
  'slice-upi',
  'bobupi',
  'sbiyono',
  'myjio',
};

class UpiLaunchResult {
  const UpiLaunchResult({required this.launched, this.fallbackUrl});

  final bool launched;

  final Uri? fallbackUrl;
}

bool isUpiIntentUri(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'intent' || kUpiAppSchemes.contains(scheme);
}

Future<UpiLaunchResult> launchUpiIntent(Uri uri) async {
  final intentUri = _parseAndroidIntentUri(uri);
  final target = intentUri == null ? uri : intentUri.target;
  final fallbackUrl = intentUri?.fallbackUrl;

  if (target != null) {
    final candidates = <Uri>[target];
    final generic = _genericUpiUri(target);
    if (generic != null) candidates.add(generic);

    for (final candidate in candidates) {
      if (await _openExternally(candidate)) {
        return UpiLaunchResult(launched: true, fallbackUrl: fallbackUrl);
      }
    }
  }

  return UpiLaunchResult(launched: false, fallbackUrl: fallbackUrl);
}

Future<NavigationActionPolicy> handleUpiIntentNavigation(
  BuildContext context,
  InAppWebViewController controller,
  Uri uri,
) async {
  if (!isUpiIntentUri(uri)) return NavigationActionPolicy.ALLOW;

  final result = await launchUpiIntent(uri);

  if (!result.launched) {
    if (result.fallbackUrl != null) {
      await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri.uri(result.fallbackUrl!)),
      );
    } else if (context.mounted) {
      showNoUpiAppSnackBar(context);
    }
  }

  return NavigationActionPolicy.CANCEL;
}

void showNoUpiAppSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text(
            'No UPI app found. Install one or pick another payment method.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
}

Future<bool> _openExternally(Uri uri) async {
  try {
    return await launchUrl(
      uri,
      mode: Platform.isIOS
          ? LaunchMode.externalNonBrowserApplication
          : LaunchMode.externalApplication,
    );
  } catch (e) {
    debugPrint('UPI intent: could not open $uri ($e)');
    return false;
  }
}

class _AndroidIntentUri {
  const _AndroidIntentUri(this.target, this.fallbackUrl);

  final Uri? target;
  final Uri? fallbackUrl;
}

_AndroidIntentUri? _parseAndroidIntentUri(Uri uri) {
  if (uri.scheme.toLowerCase() != 'intent') return null;

  String? scheme;
  Uri? fallbackUrl;

  for (final field in uri.fragment.split(';')) {
    final separator = field.indexOf('=');
    if (separator <= 0) continue;

    final key = field.substring(0, separator);
    final value = field.substring(separator + 1);
    if (key == 'scheme') {
      scheme = value;
    } else if (key == 'S.browser_fallback_url') {
      fallbackUrl = Uri.tryParse(Uri.decodeComponent(value));
    }
  }

  return _AndroidIntentUri(
    scheme == null || scheme.isEmpty
        ? null
        : Uri(
            scheme: scheme,
            host: uri.host,
            path: uri.path,
            query: uri.hasQuery ? uri.query : null,
          ),
    fallbackUrl,
  );
}

Uri? _genericUpiUri(Uri target) {
  if (target.scheme.toLowerCase() == 'upi') return null;
  if (!target.hasQuery || !target.queryParameters.containsKey('pa')) {
    return null;
  }

  return Uri(scheme: 'upi', host: 'pay', query: target.query);
}
