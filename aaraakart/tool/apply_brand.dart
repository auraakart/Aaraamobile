import 'dart:convert';
import 'dart:io';

import 'brand_utils.dart';

void main(List<String> args) {
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.isEmpty) {
    fail('Usage: dart run tool/apply_brand.dart <brandId> [--no-assets]');
  }
  final brandId = positional.first;
  final genGraphics = !args.contains('--no-assets');
  final root = Directory.current.path;
  final brandDir = brandDirFor(root, brandId);

  if (!Directory(brandDir).existsSync()) {
    fail('Brand "$brandId" not found at $brandDir');
  }

  stdout.writeln('\n=== Applying brand: $brandId ===\n');
  final config = readBrandConfig(brandDir);

  for (final key in ['brandId', 'appName', 'bundleId', 'packageName']) {
    if (str(config, key).isEmpty) fail('config.json missing required "$key"');
  }

  final appName = str(config, 'appName');
  final bundleId = str(config, 'bundleId');
  final packageName = str(config, 'packageName');
  final android = section(config, 'android');
  final ios = section(config, 'ios');
  final androidVersion = str(android, 'version');
  final androidBuildNumber = (android['buildNumber'] as num?)?.toInt() ?? 1;
  final iosVersion = str(ios, 'version');
  final iosBuildNumber = (ios['buildNumber'] as num?)?.toInt() ?? 1;
  if (androidVersion.isEmpty)
    fail('config.json missing required "android.version"');
  if (iosVersion.isEmpty) fail('config.json missing required "ios.version"');
  final maps = section(config, 'maps');
  final nativeMapsKey = str(maps, 'nativeApiKey');

  _copyRuntimeAssets(root, brandDir, brandId);
  _patchPubspec(root, androidVersion, androidBuildNumber);
  _regenerateNative(root, appName, bundleId, packageName, iosVersion,
      iosBuildNumber, nativeMapsKey);
  _copyAndroidFirebase(root, brandDir);
  _copyIosFirebase(root, brandDir);
  _generateFirebaseOptions(root, brandDir);
  _generateKeystore(root, brandDir, config);
  if (genGraphics) {
    _generateIconsAndSplash(root, config);
  } else {
    logStep('Skipping icon/splash generation (--no-assets)');
  }

  stdout.writeln('\n✓ Brand "$brandId" applied. Ready to flutter build.\n');
}

void _copyRuntimeAssets(String root, String brandDir, String brandId) {
  logStep('Copying runtime assets → assets/brand/');
  copyDirReplacing('$brandDir/assets', '$root/assets/brand');
  copyFileChecked('$brandDir/icon/icon.png', '$root/assets/brand/icon.png');
  copyFileChecked(
      '$brandDir/splash/splash.png', '$root/assets/brand/splash.png');
  copyFileChecked('$brandDir/config.json', '$root/assets/brand/config.json');
}

void _patchPubspec(String root, String androidVersion, int androidBuildNumber) {
  logStep(
      'Setting pubspec version (Android) → $androidVersion+$androidBuildNumber');
  replaceInFile(
    '$root/pubspec.yaml',
    RegExp(r'^version: .*$', multiLine: true),
    'version: $androidVersion+$androidBuildNumber',
  );
}

void _regenerateNative(
    String root,
    String appName,
    String bundleId,
    String packageName,
    String iosVersion,
    int iosBuildNumber,
    String nativeMapsKey) {
  logStep(
      'Regenerating android/ + ios/ from bricks/native_app → iOS:$bundleId Android:$packageName');
  logStep('Setting iOS version → $iosVersion+$iosBuildNumber');
  final varsFile = File('$root/.dart_tool/apply_brand_vars.json')
    ..createSync(recursive: true);
  varsFile.writeAsStringSync(jsonEncode({
    'app_name': appName,
    'bundle_id': bundleId,
    'package_name': packageName,
    'version': iosVersion,
    'build_number': '$iosBuildNumber',
    'maps_native_key': nativeMapsKey,
  }));

  run('mason', ['get'], workingDir: root);
  run(
      'mason',
      [
        'make',
        'native_app',
        '-c',
        varsFile.path,
        '-o',
        root,
        '--on-conflict',
        'overwrite',
      ],
      workingDir: root);

  final podLock = File('$root/ios/Podfile.lock');
  if (podLock.existsSync()) podLock.deleteSync();
}

void _copyAndroidFirebase(String root, String brandDir) {
  copyFileChecked('$brandDir/firebase/google-services.json',
      '$root/android/app/google-services.json');
}

void _copyIosFirebase(String root, String brandDir) {
  copyFileChecked('$brandDir/firebase/GoogleService-Info.plist',
      '$root/ios/Runner/GoogleService-Info.plist');
}

void _generateFirebaseOptions(String root, String brandDir) {
  logStep('Regenerating lib/firebase_options.dart from native Firebase files');
  final android =
      _readGoogleServicesJson('$brandDir/firebase/google-services.json');
  final ios =
      _readGoogleServicePlist('$brandDir/firebase/GoogleService-Info.plist');

  String field(String name, Map<String, String> m) {
    final v = m[name];
    if (v == null || v.isEmpty) return '';
    return "    $name: '$v',\n";
  }

  String options(String name, Map<String, String> m, List<String> keys) {
    final buffer = StringBuffer(
        '  static const FirebaseOptions $name = FirebaseOptions(\n');
    for (final k in keys) {
      buffer.write(field(k, m));
    }
    buffer.write('  );\n');
    return buffer.toString();
  }

  const androidKeys = [
    'apiKey',
    'appId',
    'messagingSenderId',
    'projectId',
    'databaseURL',
    'storageBucket'
  ];
  const iosKeys = [
    'apiKey',
    'appId',
    'messagingSenderId',
    'projectId',
    'databaseURL',
    'storageBucket',
    'androidClientId',
    'iosClientId',
    'iosBundleId'
  ];

  final content = '''
// GENERATED by tool/apply_brand.dart — do not edit by hand.
// Values are derived from brands/<brand>/firebase/google-services.json and
// GoogleService-Info.plist (the single Firebase source per brand).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return android;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        return android;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

${options('android', android, androidKeys)}
${options('ios', ios, iosKeys)}}
''';

  File('$root/lib/firebase_options.dart').writeAsStringSync(content);
  _generateFirebaseJson(root, android, ios);
}

void _generateFirebaseJson(
    String root, Map<String, String> android, Map<String, String> ios) {
  final json = {
    'flutter': {
      'platforms': {
        'android': {
          'default': {
            'projectId': android['projectId'],
            'appId': android['appId'],
            'fileOutput': 'android/app/google-services.json',
          },
        },
        'ios': {
          'default': {
            'projectId': ios['projectId'],
            'appId': ios['appId'],
            'uploadDebugSymbols': false,
            'fileOutput': 'ios/Runner/GoogleService-Info.plist',
          },
        },
        'dart': {
          'lib/firebase_options.dart': {
            'projectId': android['projectId'],
            'configurations': {
              'android': android['appId'],
              'ios': ios['appId'],
            },
          },
        },
      },
    },
  };
  File('$root/firebase.json').writeAsStringSync(jsonEncode(json));
}

Map<String, String> _readGoogleServicesJson(String path) {
  final file = File(path);
  if (!file.existsSync()) fail('Missing $path');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final info = json['project_info'] as Map<String, dynamic>? ?? {};
  final clients = json['client'] as List? ?? [];
  if (clients.isEmpty) fail('No client entry in $path');
  final client = clients.first as Map<String, dynamic>;
  final clientInfo = client['client_info'] as Map<String, dynamic>? ?? {};
  final apiKeys = client['api_key'] as List? ?? [];
  return {
    'apiKey': apiKeys.isNotEmpty
        ? (apiKeys.first as Map)['current_key']?.toString() ?? ''
        : '',
    'appId': clientInfo['mobilesdk_app_id']?.toString() ?? '',
    'messagingSenderId': info['project_number']?.toString() ?? '',
    'projectId': info['project_id']?.toString() ?? '',
    'storageBucket': info['storage_bucket']?.toString() ?? '',
    'databaseURL': info['firebase_url']?.toString() ?? '',
  };
}

Map<String, String> _readGoogleServicePlist(String path) {
  final file = File(path);
  if (!file.existsSync()) fail('Missing $path');
  final plist = _parsePlist(file.readAsStringSync());
  return {
    'apiKey': plist['API_KEY'] ?? '',
    'appId': plist['GOOGLE_APP_ID'] ?? '',
    'messagingSenderId': plist['GCM_SENDER_ID'] ?? '',
    'projectId': plist['PROJECT_ID'] ?? '',
    'storageBucket': plist['STORAGE_BUCKET'] ?? '',
    'databaseURL': plist['DATABASE_URL'] ?? '',
    'androidClientId': plist['ANDROID_CLIENT_ID'] ?? '',
    'iosClientId': plist['CLIENT_ID'] ?? '',
    'iosBundleId': plist['BUNDLE_ID'] ?? '',
  };
}

Map<String, String> _parsePlist(String xml) {
  final result = <String, String>{};
  final re =
      RegExp(r'<key>([^<]+)</key>\s*<string>([^<]*)</string>', multiLine: true);
  for (final m in re.allMatches(xml)) {
    result[m.group(1)!] = m.group(2)!;
  }
  return result;
}

void _generateKeystore(
    String root, String brandDir, Map<String, dynamic> config) {
  final ks = section(config, 'keystore');
  final storeFile = str(ks, 'storeFile');
  final storePassword = str(ks, 'storePassword');
  final keyProps = File('$root/android/key.properties');
  final src = File('$brandDir/keystore/$storeFile');

  if (storeFile.isEmpty || storePassword.isEmpty || !src.existsSync()) {
    if (keyProps.existsSync()) keyProps.deleteSync();
    logStep(
        'No release keystore configured → release builds will fail closed; debug builds remain available');
    return;
  }

  logStep('Configuring Android release signing → $storeFile');
  copyFileChecked(src.path, '$root/android/app/$storeFile');
  keyProps.writeAsStringSync('''
storeFile=$storeFile
storePassword=$storePassword
keyAlias=${str(ks, 'keyAlias')}
keyPassword=${str(ks, 'keyPassword')}
''');
}

void _generateIconsAndSplash(String root, Map<String, dynamic> config) {
  logStep('Generating launcher icons and splash screen');
  final theme = section(config, 'theme');
  final bg = str(theme, 'whiteColor', fallback: '#FFFFFF');

  logStep('Padding icon/splash onto square canvases');
  padImageToSquare(
    '$root/assets/brand/icon.png',
    '$root/assets/brand/icon_square.png',
    marginFraction: 0.20,
  );
  padImageToSquare(
    '$root/assets/brand/splash.png',
    '$root/assets/brand/splash_square.png',
    marginFraction: 0.35,
  );

  File('$root/flutter_launcher_icons.yaml').writeAsStringSync('''
# GENERATED by tool/apply_brand.dart
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  remove_alpha_ios: true
  background_color_ios: "$bg"
  image_path: "assets/brand/icon_square.png"
  adaptive_icon_background: "$bg"
  adaptive_icon_foreground: "assets/brand/icon_square.png"
''');

  File('$root/flutter_native_splash.yaml').writeAsStringSync('''
# GENERATED by tool/apply_brand.dart
flutter_native_splash:
  color: "$bg"
  image: assets/brand/splash_square.png
  android_12:
    color: "$bg"
    image: assets/brand/splash_square.png
    icon_background_color: "$bg"
''');

  run('dart',
      ['run', 'flutter_launcher_icons', '-f', 'flutter_launcher_icons.yaml'],
      workingDir: root);
  run(
      'dart',
      [
        'run',
        'flutter_native_splash:create',
        '--path',
        'flutter_native_splash.yaml'
      ],
      workingDir: root);
}
