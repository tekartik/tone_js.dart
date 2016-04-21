@TestOn("browser")
import 'package:tone_js/tone_js_loader.dart';
import 'package:dev_test/test.dart';
import 'dart:js' as js;

void main() {
  group('loader', () {
    test('load', () async {
      expect(js.context['Tone'], isNull);
      await (loadToneJs());
      expect(js.context['Tone'], isNotNull);
    });
  });
}
