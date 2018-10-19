@TestOn("browser")
library tekartik_tone_js.test.tone_js_test;

import 'package:tekartik_tone_js/tone.dart';
import 'package:tekartik_tone_js/tone_js_loader.dart';
import 'package:dev_test/test.dart';

main() {
  group('Tone', () {
    setUpAll(() async {
      await loadToneJs();
    });
    test('version', () {
      expect(toneContext.version, "r6");
    });
  }, skip: true);
}
