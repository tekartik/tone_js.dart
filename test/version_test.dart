@TestOn('browser')
library tekartik_tone_js.test.version_test;

import 'package:tekartik_tone_js/tone.dart';

import 'package:dev_test/test.dart';

void main() {
  test('version', () async {
    expect(toneContext, isNull);
    await initToneContext();
    expect(toneContext, isNotNull);
    expect(toneContext.version, 'r12');
  });
}
