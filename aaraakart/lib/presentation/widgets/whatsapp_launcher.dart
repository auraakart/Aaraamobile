import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Converts a WhatsApp number into international format.
///
/// Examples:
/// 9362333777       -> 919362333777
/// 09362333777      -> 919362333777
/// 919362333777     -> 919362333777
/// 00919362333777   -> 919362333777
String normaliseWhatsAppNumber(
  String raw, {
  String countryCode = '91',
}) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  final String code = countryCode.replaceAll(RegExp(r'\D'), '');

  if (digits.isEmpty) {
    return '';
  }

  // Convert 0091XXXXXXXXXX -> 91XXXXXXXXXX
  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }

  // Remove leading zero(s) from local number.
  while (digits.startsWith('0')) {
    digits = digits.substring(1);
  }

  if (digits.isEmpty) {
    return '';
  }

  // Add country code if it isn't already present.
  if (code.isNotEmpty && !digits.startsWith(code)) {
    digits = '$code$digits';
  }

  return digits;
}

/// Opens WhatsApp with the supplied phone number and message.
///
/// Priority:
/// 1. Native WhatsApp application (`LaunchMode.externalNonBrowserApplication`)
/// 2. WhatsApp HTTPS fallback (`LaunchMode.externalApplication`)
Future<void> handleWhatsAppLauncher(
  String mobileNumber,
  String msg,
  BuildContext context, {
  String countryCode = '91',
}) async {
  final String contact = normaliseWhatsAppNumber(
    mobileNumber,
    countryCode: countryCode,
  );

  if (contact.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support number is not available.'),
        ),
      );
    }
    return;
  }

  final String encodedMessage = Uri.encodeComponent(msg);

  // Native WhatsApp application URI.
  final Uri appUri = Uri.parse(
    'whatsapp://send?phone=$contact&text=$encodedMessage',
  );

  // HTTPS fallback URI.
  final Uri webUri = Uri.parse(
    'https://wa.me/$contact?text=$encodedMessage',
  );

  debugPrint('WhatsApp contact: $contact');
  debugPrint('WhatsApp app URI: $appUri');
  debugPrint('WhatsApp web URI: $webUri');

  // ------------------------------------------------------------
  // 1. Try native WhatsApp application first
  // ------------------------------------------------------------
  try {
    if (await canLaunchUrl(appUri)) {
      final bool launched = await launchUrl(
        appUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (launched) {
        debugPrint('Native WhatsApp app launched successfully');
        return;
      }
    }
  } catch (e) {
    debugPrint('Native WhatsApp app launch error: $e');
  }

  // ------------------------------------------------------------
  // 2. Fallback to WhatsApp HTTPS URL
  // ------------------------------------------------------------
  try {
    if (await canLaunchUrl(webUri)) {
      final bool launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        debugPrint('WhatsApp web fallback launched successfully');
        return;
      }
    }
  } catch (e) {
    debugPrint('WhatsApp web fallback launch error: $e');
  }

  // ------------------------------------------------------------
  // 3. Fallback error notification
  // ------------------------------------------------------------
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open WhatsApp. Please make sure WhatsApp is installed.',
        ),
      ),
    );
  }
}
