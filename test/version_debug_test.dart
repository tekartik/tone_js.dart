@TestOn('browser')
library tekartik_tone_js.test.version_debug_test;

import 'package:tekartik_tone_js/src/tone.dart';
import 'package:test/test.dart';

void main() {
  test('version', () async {
    expect(toneContextOrNull, isNull);
    var localToneContext = await initToneContext(debug: true);
    expect(localToneContext.version, '14.7.77');
    expect(toneContext, localToneContext);
  });
}
