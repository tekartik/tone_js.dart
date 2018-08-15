@JS()
library tekartik_tone_js.test_import;

import 'package:tekartik_tone_js/tone_js_loader.dart';
import 'package:tekartik_tone_js/tone_js.dart';
import 'package:tekartik_tone_js/src/import_lite.dart';

export 'package:tekartik_tone_js/tone_js.dart';
export 'package:dev_test/test.dart';

import 'package:js/js.dart';

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

Test createTest() {
  Test test = new Test(input: context.createGain());
  return test;
}

connectTest(Test test, node, [inputNumber]) {
  test.input.connect(node, 0, inputNumber);
  test.input.disconnect();
}
