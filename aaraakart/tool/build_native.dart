import 'dart:io';

import 'brand_utils.dart';

void main(List<String> args) {
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.isEmpty) {
    fail(
        'Usage: dart run tool/build_native.dart <brandId> [--platform=android|ios|both] '
        '[--mode=release|debug] [--android-artifact=apk|aab|both] [--no-assets]');
  }
  final brandId = positional.first;
  final platform = _option(args, 'platform', 'both');
  final mode = _option(args, 'mode', 'release');
  final androidArtifact = _option(args, 'android-artifact', 'apk');
  final noAssets = args.contains('--no-assets');

  if (!['android', 'ios', 'both'].contains(platform)) {
    fail('--platform must be android, ios, or both');
  }
  if (!['release', 'debug'].contains(mode)) {
    fail('--mode must be release or debug');
  }
  if (!['apk', 'aab', 'both'].contains(androidArtifact)) {
    fail('--android-artifact must be apk, aab, or both');
  }

  final root = Directory.current.path;

  stdout.writeln('\n=== Building "$brandId" ($platform, $mode) ===\n');

  logStep('Installing dependencies');
  run('flutter', ['pub', 'get'], workingDir: root);

  logStep('Applying brand "$brandId"');
  final applyArgs = ['run', 'tool/apply_brand.dart', brandId];
  if (noAssets) applyArgs.add('--no-assets');
  run('dart', applyArgs, workingDir: root);

  final distDir = Directory('$root/dist')..createSync(recursive: true);

  if (platform == 'android' || platform == 'both') {
    _buildAndroid(root, distDir.path, brandId, mode, androidArtifact);
  }
  if (platform == 'ios' || platform == 'both') {
    _buildIos(root, distDir.path, brandId, mode);
  }

  stdout.writeln('\n✓ Build complete. Artifacts in dist/\n');
}

String _option(List<String> args, String name, String fallback) {
  final prefix = '--$name=';
  final match = args.firstWhere((a) => a.startsWith(prefix), orElse: () => '');
  return match.isEmpty ? fallback : match.substring(prefix.length);
}

void _buildAndroid(
    String root, String distDir, String brandId, String mode, String artifact) {
  logStep('Building Android ($artifact, $mode)');

  if (artifact == 'apk' || artifact == 'both') {
    run('flutter', ['build', 'apk', '--$mode'], workingDir: root);
    copyFileChecked(
      '$root/build/app/outputs/flutter-apk/app-$mode.apk',
      '$distDir/$brandId-$mode.apk',
    );
  }
  if (artifact == 'aab' || artifact == 'both') {
    run('flutter', ['build', 'appbundle', '--$mode'], workingDir: root);
    copyFileChecked(
      '$root/build/app/outputs/bundle/$mode/app-$mode.aab',
      '$distDir/$brandId-$mode.aab',
    );
  }
}

void _buildIos(String root, String distDir, String brandId, String mode) {
  if (!Platform.isMacOS) {
    logStep('Skipping iOS build (not running on macOS)');
    return;
  }

  logStep('Building iOS ($mode, no codesign)');
  final pbxproj = '$root/ios/Runner.xcodeproj/project.pbxproj';
  replaceInFile(
    pbxproj,
    RegExp(
        r'OTHER_SWIFT_FLAGS = (?!\$\(inherited\) -enable-experimental-feature)'),
    r'OTHER_SWIFT_FLAGS = $(inherited) -enable-experimental-feature AccessLevelOnImport;',
    required: false,
  );

  run('flutter', ['build', 'ios', '--$mode', '--no-codesign'],
      workingDir: root);

  final iphoneosDir = '$root/build/ios/iphoneos';
  final payloadDir = Directory('$iphoneosDir/Payload');
  if (payloadDir.existsSync()) payloadDir.deleteSync(recursive: true);
  payloadDir.createSync(recursive: true);
  Directory('$iphoneosDir/Runner.app')
      .renameSync('${payloadDir.path}/Runner.app');

  final ipaName = '$brandId-$mode-FlutterIpaExport.ipa';
  run('zip', ['-qq', '-r', '-9', ipaName, 'Payload'], workingDir: iphoneosDir);
  copyFileChecked('$iphoneosDir/$ipaName', '$distDir/$ipaName');
}
