import 'package:process_run/shell.dart';

Future<void> main() async {
  var shell = Shell();

  await shell.run('''

  dart pub run build_runner test -- -p chrome

''');
}
