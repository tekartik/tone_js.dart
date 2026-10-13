/// tone_api.dart and tone_web.dart can be imported on any platform.
library;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_tone_js/tone_api.dart';
import 'package:tekartik_tone_js/tone_web.dart';
import 'package:test/test.dart';

void main() {
  test('factories', () {
    expect(toneFactoryJs.name, 'tone_js');
    expect(toneFactoryWeb.name, 'tone_web');
    expect(toneFactoryJs.isSupported, kDartIsWeb);
    expect(toneFactoryWeb.isSupported, kDartIsWeb);
    expect(isToneWebSupported, kDartIsWeb);
  });

  test('io', () async {
    expect(toneWebContextOrNull, isNull);
    expect(() => toneWebContext, throwsA(isA<Error>()));
    await expectLater(initToneWebContext(), throwsUnsupportedError);
    await expectLater(toneFactoryWeb.initContext(), throwsUnsupportedError);
    await expectLater(toneFactoryJs.initContext(), throwsUnsupportedError);
  }, testOn: 'vm');
}
