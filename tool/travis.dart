import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''

  dartanalyzer --fatal-warnings example lib test tool
  pub run test -p vm,firefox,chrome

''');

  /*
  await shell.run('''

  pub run build_runner test -- -p chrome

''');

   */
}
