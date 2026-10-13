@TestOn('browser')
library;

import 'package:tekartik_tone_js/tone.dart';
import 'package:test/test.dart';

import 'src/test_wav.dart';

void main() {
  group('sampler', () {
    setUpAll(() async {
      await initToneContext();
    });
    test('create', () async {
      var sampler = await toneContext
          .createSampler({'C4': pluckWavDataUrl(261.6255653005986)})
          .timeout(const Duration(seconds: 10));
      expect(sampler.toDestination(), isA<Sampler>());
    });
    test('missing file', () async {
      // Used to never complete, StateError as in tone_web.
      await expectLater(
        toneContext
            .createSampler({'C4': '../example/audio/dummy.mp3'})
            .timeout(const Duration(seconds: 10)),
        throwsStateError,
      );
    });
  });
}
