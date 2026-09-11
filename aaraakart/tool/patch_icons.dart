import 'dart:io';

void main() {
  final dir = Directory('local_packages/icons_plus/lib/src');
  if (!dir.existsSync()) {
    print('Directory not found: ${dir.path}');
    return;
  }

  for (final file in dir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;
    String content = file.readAsStringSync();

    final regex = RegExp(
      r'class\s+(\w+IconData)\s+extends\s+IconData\s*\{\s*const\s+\w+\(int\s+code\)\s*:\s*super\(\s*code,\s*fontFamily:\s*[\x27"]([^\x27"]+)[\x27"],\s*fontPackage:\s*[\x27"]([^\x27"]+)[\x27"],\s*\);\s*\}',
      multiLine: true,
    );

    final match = regex.firstMatch(content);
    if (match != null) {
      final className = match.group(1)!;
      final fontFamily = match.group(2)!;
      final fontPackage = match.group(3)!;

      content = content.replaceFirst(regex, '');

      final iconCallRegex = RegExp('$className\\((0x[0-9a-fA-F]+|[0-9]+)\\)');
      content = content.replaceAllMapped(
        iconCallRegex,
        (m) => "IconData(${m.group(1)}, fontFamily: '$fontFamily', fontPackage: '$fontPackage')",
      );

      file.writeAsStringSync(content);
      print('Patched ${file.path} ($className -> $fontFamily)');
    }
  }

  print('Done patching icons_plus!');
}
