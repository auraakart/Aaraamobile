import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

void logStep(String message) => stdout.writeln('• $message');
void logInfo(String message) => stdout.writeln('    $message');

Never fail(String message) {
  stderr.writeln('✗ $message');
  exit(1);
}

String workspaceRoot(String projectRoot) => Directory(projectRoot).parent.path;

String brandDirFor(String projectRoot, String brandId) =>
    '${workspaceRoot(projectRoot)}/brands/$brandId';

Map<String, dynamic> readBrandConfig(String brandDir) {
  final file = File('$brandDir/config.json');
  if (!file.existsSync()) {
    fail('Brand config not found: ${file.path}');
  }
  try {
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    fail('Failed to parse ${file.path}: $e');
  }
}

Map<String, dynamic> section(Map<String, dynamic> json, String key) =>
    json[key] is Map<String, dynamic>
        ? json[key] as Map<String, dynamic>
        : <String, dynamic>{};

String str(Map<String, dynamic> json, String key, {String fallback = ''}) =>
    json[key]?.toString() ?? fallback;

void replaceInFile(String path, Pattern pattern, String replacement,
    {bool required = true}) {
  final file = File(path);
  if (!file.existsSync()) {
    if (required) fail('Expected file missing: $path');
    return;
  }
  final original = file.readAsStringSync();
  final matched = pattern.allMatches(original).isNotEmpty;
  if (!matched && required) {
    final p = pattern is RegExp ? pattern.pattern : pattern.toString();
    fail('No match for /$p/ in $path — template may have changed.');
  }

  final updated =
      original.replaceAllMapped(pattern, (m) => _expandGroups(replacement, m));
  if (original != updated) file.writeAsStringSync(updated);
}

String _expandGroups(String replacement, Match match) {
  return replacement.replaceAllMapped(RegExp(r'\$(\d)'), (ref) {
    final index = int.parse(ref.group(1)!);
    return index <= match.groupCount
        ? (match.group(index) ?? '')
        : ref.group(0)!;
  });
}

void copyFileChecked(String from, String to) {
  final src = File(from);
  if (!src.existsSync()) fail('Missing source file: $from');
  Directory(File(to).parent.path).createSync(recursive: true);
  src.copySync(to);
}

void copyFileIfExists(String from, String to) {
  final src = File(from);
  if (!src.existsSync()) return;
  Directory(File(to).parent.path).createSync(recursive: true);
  src.copySync(to);
}

void copyDirReplacing(String from, String to) {
  final src = Directory(from);
  if (!src.existsSync()) fail('Missing source directory: $from');
  final dst = Directory(to);
  if (dst.existsSync()) dst.deleteSync(recursive: true);
  dst.createSync(recursive: true);
  for (final entity in src.listSync(recursive: true)) {
    final rel = entity.path.substring(src.path.length);
    final target = '${dst.path}$rel';
    if (entity is Directory) {
      Directory(target).createSync(recursive: true);
    } else if (entity is File) {
      Directory(File(target).parent.path).createSync(recursive: true);
      entity.copySync(target);
    }
  }
}

void padImageToSquare(String srcPath, String destPath,
    {double marginFraction = 0.15}) {
  final src = File(srcPath);
  if (!src.existsSync()) fail('Missing source image: $srcPath');

  final decoded = img.decodeImage(src.readAsBytesSync());
  if (decoded == null) fail('Could not decode image: $srcPath');

  final w = decoded.width, h = decoded.height;
  final corners = [
    decoded.getPixel(0, 0),
    decoded.getPixel(w - 1, 0),
    decoded.getPixel(0, h - 1),
    decoded.getPixel(w - 1, h - 1),
  ];
  final bgR = (corners.map((p) => p.r).reduce((a, b) => a + b) / 4).round();
  final bgG = (corners.map((p) => p.g).reduce((a, b) => a + b) / 4).round();
  final bgB = (corners.map((p) => p.b).reduce((a, b) => a + b) / 4).round();
  const bgTolerance = 20 * 20 * 3;

  bool isBackground(int x, int y) {
    final p = decoded.getPixel(x, y);
    if (p.a < 10) return true;
    final dr = p.r - bgR, dg = p.g - bgG, db = p.b - bgB;
    return (dr * dr + dg * dg + db * db) < bgTolerance;
  }

  bool rowIsMargin(int y) {
    var nonBg = 0;
    for (var x = 0; x < w; x++) {
      if (!isBackground(x, y)) nonBg++;
    }
    return nonBg / w < 0.01;
  }

  bool colIsMargin(int x) {
    var nonBg = 0;
    for (var y = 0; y < h; y++) {
      if (!isBackground(x, y)) nonBg++;
    }
    return nonBg / h < 0.01;
  }

  var top = 0;
  while (top < h && rowIsMargin(top)) top++;
  var bottom = h - 1;
  while (bottom > top && rowIsMargin(bottom)) bottom--;
  var left = 0;
  while (left < w && colIsMargin(left)) left++;
  var right = w - 1;
  while (right > left && colIsMargin(right)) right--;

  final cropped = img.copyCrop(decoded,
      x: left, y: top, width: right - left + 1, height: bottom - top + 1);

  final longSide =
      cropped.width > cropped.height ? cropped.width : cropped.height;
  final canvasSize = (longSide / (1 - 2 * marginFraction)).round();

  final canvas = img.Image(
    width: canvasSize,
    height: canvasSize,
    numChannels: 4,
  );
  img.fill(canvas, color: img.ColorRgba8(bgR, bgG, bgB, 255));
  img.compositeImage(
    canvas,
    cropped,
    dstX: (canvasSize - cropped.width) ~/ 2,
    dstY: (canvasSize - cropped.height) ~/ 2,
  );

  Directory(File(destPath).parent.path).createSync(recursive: true);
  File(destPath).writeAsBytesSync(img.encodePng(canvas));
}

void run(String executable, List<String> args, {String? workingDir}) {
  logInfo('\$ $executable ${args.join(' ')}');
  final result = Process.runSync(executable, args,
      workingDirectory: workingDir, runInShell: true);
  if (result.stdout.toString().trim().isNotEmpty) {
    stdout.writeln(result.stdout.toString().trimRight());
  }
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr.toString().trimRight());
    fail('Command failed ($executable) with exit code ${result.exitCode}');
  }
}
