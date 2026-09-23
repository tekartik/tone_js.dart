/// tone_web on a realtime audio context (no sound expected in tests).
@TestOn('browser')
library;

import 'package:tekartik_tone_js/tone_web.dart';
import 'package:test/test.dart';

import 'src/test_wav.dart';

void main() {
  group('tone_web', () {
    late ToneWebContext context;
    setUpAll(() async {
      expect(toneWebContextOrNull, isNull);
      context = await initToneWebContext();
    });

    test('context', () async {
      expect(context.version, toneWebVersion);
      expect(toneWebContext, same(context));
      expect(await initToneWebContext(), same(context));
      expect(await toneFactoryWeb.initContext(), same(context));
      expect(context.lookAhead, 0.1);
      expect(context.now(), closeTo(context.currentTime + 0.1, 1e-9));
      expect(await initToneWebContext(lookAhead: 0.05), same(context));
      expect(context.lookAhead, 0.05);
      context.lookAhead = 0.1;
    });

    test('synth', () {
      var synth = context.newSynth().toDestination();
      synth
        ..triggerAttackRelease('C4', '8n')
        ..triggerAttackRelease('E4', 0.5, delay: 0.5)
        ..triggerAttack('G4', delay: '4n')
        ..triggerRelease(delay: 1);
      expect(
        () => synth.triggerAttack('H4'),
        throwsArgumentError,
        reason: 'invalid note',
      );
      expect(
        () => synth.triggerAttackRelease('C4', 'dummy'),
        throwsArgumentError,
        reason: 'invalid duration',
      );
    });

    test('sampler', () async {
      var sampler = (await context.createSampler({
        'C4': pluckWavDataUrl(261.6255653005986),
      })).toDestination();
      sampler
        ..triggerAttack('C4')
        ..triggerAttackRelease('Bb3', 0.5, delay: 1.0)
        ..triggerAttackRelease('C#3', '4n', delay: 2.0)
        ..triggerRelease('C4', delay: 0.5);
    });

    test('sampler files', () async {
      var sampler = await context.createSampler({
        'C4': 'C4[.mp3|.ogg]',
      }, baseUrl: '../example/audio/');
      sampler.toDestination().triggerAttackRelease('D4', 1);
    });

    test('sampler missing file', () async {
      await expectLater(
        context.createSampler({'C4': '../example/audio/dummy.mp3'}),
        throwsStateError,
      );
    });

    test('api', () async {
      // Implementation agnostic code
      Future<void> play(ToneFactory factory) async {
        var context = await factory.initContext();
        context.newSynth().toDestination().triggerAttackRelease('A4', '16n');
      }

      await play(toneFactoryWeb);
    });
  });
}
