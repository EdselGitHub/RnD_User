import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  int count = 0;
  for (var file in files) {
    var content = file.readAsStringSync();
    if (content.contains('core/data/models/')) {
      content = content.replaceAll('core/data/models/', 'core/models/');
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
      count++;
    }
  }
  print('Updated $count files.');
}
