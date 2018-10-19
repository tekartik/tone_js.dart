@TestOn("browser")
library tekartik_tone_js.test.tone_js_loader_test;

import 'package:tekartik_tone_js/tone_js_loader.dart';
import 'package:dev_test/test.dart';

void main() {
  group('loader', () {
    test('load', () async {
      // expect(js.context['Tone'], isNull);
      // expect(isToneJsLoaded, isFalse);
      await (loadToneJs());
      // expect(js.context['Tone'], isNotNull);
      // expect(isToneJsLoaded, isTrue);
    });
  }, skip: true);
}
