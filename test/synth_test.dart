@TestOn('browser')
library tekartik_tone_js.test.synth_test;

import 'package:tekartik_tone_js/tone.dart';

import 'package:dev_test/test.dart';

void main() {
  group('synth', () {
    setUpAll(() async {
      await initToneContext();
    });
    test('create', () {
      var synth = Synth();
      synth = synth.toMaster();
      expect(synth, isNotNull);
    });
  });
}
