@TestOn("browser")
library tekartik_tone_js.test.version_debug_test;

import 'package:tekartik_tone_js/tone.dart';

import 'package:dev_test/test.dart';

void main() {
  test('version', () async {
    expect(toneContext, isNull);
    var localToneContext = await initToneContext(debug: true);
    expect(localToneContext.version, 'r12');
    expect(toneContext, localToneContext);
  });
}
