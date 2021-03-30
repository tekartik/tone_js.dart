@JS()
library tekartik_tone_js.test_import;

import 'package:js/js.dart';
import 'package:tekartik_tone_js/src/import_lite.dart';
import 'package:tekartik_tone_js/tone.dart';
import 'package:tekartik_tone_js/tone_js.dart';
import 'package:tekartik_tone_js/tone_js_loader.dart';

export 'package:tekartik_tone_js/tone_js.dart';
// export 'package:dev_test/test.dart';

Future toneJsSetup() async {
  await loadToneJs();
}

@JS()
@anonymous
class Test {
  external factory Test({GainNode input});

  external GainNode get input;

  external set input(GainNode node);
}

Future<Test> createTest() async {
  var test = Test(input: (await initToneContext()).context.createGain());
  return test;
}

void connectTest(Test test, node, [inputNumber]) {
  test.input.connect(node, 0, inputNumber);
  test.input.disconnect();
}
