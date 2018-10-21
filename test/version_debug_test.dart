@TestOn("browser")
library tekartik_tone_js.test.version_debug_test;

import 'package:tekartik_tone_js/tone.dart';

import 'package:dev_test/test.dart';

void main() {
  test('version', () async {
    expect(toneContext, isNull);
    var toneContext_ = await initToneContext(debug: true);
    expect(toneContext_.version, 'r12');
    expect(toneContext, toneContext_);
  });
}
