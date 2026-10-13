@TestOn('browser')
library;

import 'package:tekartik_tone_js/src/instrument.dart';
import 'package:tekartik_tone_js/tone.dart';
import 'package:test/test.dart';

void main() {
  group('synth', () {
    setUpAll(() async {
      await initToneContext();
    });
    test('create', () async {
      var synth = Synth();
      // Tone.js toDestination returns the same native instance.
      expect(synth.toDestination().instrumentJs, synth.instrumentJs);
      // No sound in unit test
      //synth.triggerAttackRelease('C4', '8n');
      //await sleep(2500);
    });
  });
}
