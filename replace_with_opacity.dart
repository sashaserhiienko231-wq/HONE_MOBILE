import 'dart:io';

void main() async {
  final dir = Directory('lib');
  await for (var entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = await entity.readAsString();
      var newContent = content.replaceAllMapped(RegExp(r'\.withOpacity\(([^)]+)\)'), (m) {
        var value = m.group(1)!.trim();
        return '.withValues(alpha: (${value} * 255).toInt())';
      });
      if (newContent != content) {
        await entity.writeAsString(newContent);
        print('Updated ${entity.path}');
      }
    }
  }
}
