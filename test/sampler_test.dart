@TestOn('browser')
library tekartik_tone_js.test.sampler_test;

import 'package:dev_test/test.dart';
import 'package:tekartik_tone_js/tone.dart';

void main() {
  group('sampler', () {
    setUpAll(() async {
      await initToneContext();
    });
    test('create', () async {
      // await toneContext.createSampler({});
    });
  });
}
