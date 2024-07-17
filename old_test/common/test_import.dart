@JS()
library tekartik_tone_js.test_import;

import 'package:js/js.dart';
import 'package:tekartik_tone_js/src/import_lite.dart';
// ignore: unused_import
import 'package:tekartik_tone_js/src/js_interop_compat.dart';
import 'package:tekartik_tone_js/tone.dart';
import 'package:tekartik_tone_js/tone_js_loader.dart';

// export 'package:test/test.dart';

Future toneJsSetup() async {
  await loadToneJs();
}

class Test {
  final ToneGainNode input;

  Test({required this.input});
}

Future<Test> createTest() async {
  var test = Test(input: (await initToneContext()).context.createGain());
  return test;
}
/*
void connectTest(Test test, Object? node, [Object? inputNumber]) {
  test.input.connect(node, 0, inputNumber);
  test.input.disconnect();
}
*/
