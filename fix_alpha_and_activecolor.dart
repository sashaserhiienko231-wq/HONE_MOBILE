import 'dart:io';
import 'dart:convert';

final directory = Directory('f:/HONE_MOBILE');

final alphaRegex = RegExp(r'withValues\(alpha:\s*(\d+)\)');
final activeColorRegex = RegExp(r'\.activeThumbColor\b');

void fixFile(File file) {
  final original = file.readAsStringSync();
  var updated = original.replaceAllMapped(alphaRegex, (match) => 'withValues(alpha: ${match[1]}.0)');
  updated = updated.replaceAll(activeColorRegex, '.activeThumbColor');
  if (updated != original) {
    file.writeAsStringSync(updated);
    print('Updated \\${file.path}');
  }
}

void main() {
  final dartFiles = directory
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>();
  for (final file in dartFiles) {
    fixFile(file);
  }
}
