import 'dart:io';
import 'brand_utils.dart';

void main() {
  final root = Directory.current.path;
  final config = readBrandConfig('$root/../brands/madrasmilk');
  final theme = section(config, 'theme');
  final bg = str(theme, 'whiteColor', fallback: '#FFFFFF');

  print('Padding icon and splash images...');
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
flutter_native_splash:
  color: "$bg"
  android: true
  ios: false
  image: assets/brand/splash_square.png
  android_12:
    color: "$bg"
    image: assets/brand/splash_square.png
    icon_background_color: "$bg"
''');

  print('Running flutter_launcher_icons...');
  run('dart', ['run', 'flutter_launcher_icons', '-f', 'flutter_launcher_icons.yaml'], workingDir: root);

  print('Running flutter_native_splash...');
  run('dart', ['run', 'flutter_native_splash:create', '--path', 'flutter_native_splash.yaml'], workingDir: root);

  print('Graphics generation complete!');
}
