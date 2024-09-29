@TestOn('browser')
library;

import 'package:tekartik_tone_js/tone.dart';
import 'package:test/test.dart';

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
