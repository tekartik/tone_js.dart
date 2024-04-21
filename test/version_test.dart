@TestOn('browser')
library tekartik_tone_js.test.version_test;

import 'package:dev_test/test.dart';
import 'package:tekartik_tone_js/src/tone.dart';

void main() {
  test('version', () async {
    expect(toneContextOrNull, isNull);
    await initToneContext();
    expect(toneContextOrNull, isNotNull);
    expect(toneContext.version, '14.7.77');
  });
}
