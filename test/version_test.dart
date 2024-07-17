@TestOn('browser')
library tekartik_tone_js.test.version_test;

import 'package:tekartik_tone_js/src/tone.dart';
import 'package:test/test.dart';

void main() {
  test('version', () async {
    expect(toneContextOrNull, isNull);
    await initToneContext();
    expect(toneContextOrNull, isNotNull);
    expect(toneContext.version, '14.7.77');
  });
}
