@TestOn('browser')
library tekartik_tone_js.test.synth_test;

import 'package:tekartik_tone_js/tone.dart';
import 'package:test/test.dart';

void main() {
  group('synth', () {
    setUpAll(() async {
      await initToneContext();
    });
    test('create', () async {
      var synth = Synth();
      synth = synth.toDestination();
      expect(synth, isNotNull);
      // No sound in unit test
      //synth.triggerAttackRelease('C4', '8n');
      //await sleep(2500);
    });
  });
}
