/// Compares tone_web with Tone.js (through the tone_js wrapper): the same
/// scenario, written with the common API, is rendered offline by both
/// implementations and the samples are compared.
@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:tekartik_tone_js/src/common/tone_envelope.dart';
import 'package:tekartik_tone_js/src/common/tone_param.dart';
import 'package:tekartik_tone_js/src/common/tone_time.dart';
import 'package:tekartik_tone_js/tone.dart';
import 'package:test/test.dart';

import 'src/test_wav.dart';
import 'src/tone_render.dart';

typedef _Scenario = FutureOr<void> Function(ToneContextApi context);

/// Same output up to float rounding.
const _maxDiff = 1e-5;

final _c4Url = pluckWavDataUrl(toneMtof(60));
final _a4Url = pluckWavDataUrl(toneMtof(69));
final _e4Url = pluckWavDataUrl(toneMtof(64));

void main() {
  setUpAll(() async {
    await initToneContext();
  });

  Future<void> expectSameRender(
    _Scenario scenario, {
    double duration = 2,
  }) async {
    var expected = await renderToneJs(scenario, duration: duration);
    var actual = await renderToneWeb(scenario, duration: duration);
    expect(actual.length, expected.length);
    var diff = RenderDiff(expected, actual);
    expect(diff.expectedPeak, greaterThan(0.01), reason: 'silent Tone.js');
    expect(
      RenderDiff.firstSoundIndex(actual),
      RenderDiff.firstSoundIndex(expected),
      reason: '$diff',
    );
    expect(diff.maxDiff, lessThan(_maxDiff), reason: '$diff');
  }

  group('synth', () {
    test('triggerAttackRelease 8n', () async {
      await expectSameRender((context) {
        context.newSynth().toDestination().triggerAttackRelease(
          'C4',
          '8n',
          delay: 0.1,
        );
      });
    });
    test('triggerAttackRelease no delay', () async {
      await expectSameRender((context) {
        context.newSynth().toDestination().triggerAttackRelease('A4', 0.5);
      });
    });
    test('triggerAttack triggerRelease', () async {
      await expectSameRender((context) {
        context.newSynth().toDestination()
          ..triggerAttack('A4', delay: 0.1)
          ..triggerRelease(delay: 0.6);
      });
    });
    test('separate notes', () async {
      await expectSameRender((context) {
        context.newSynth().toDestination()
          ..triggerAttackRelease('C4', 0.2, delay: 0.1)
          // after the end of the release, new oscillator
          ..triggerAttackRelease('G4', 0.2, delay: 1.5);
      }, duration: 3);
    });
    test('overlapping notes', () async {
      await expectSameRender((context) {
        context.newSynth().toDestination()
          ..triggerAttackRelease('C4', '4n', delay: 0.1)
          // during the release of C4
          ..triggerAttackRelease('E4', '4n', delay: 0.8)
          // during the decay of E4
          ..triggerAttackRelease('G4', '8n', delay: 0.85);
      });
    });
    test('release during attack and decay', () async {
      await expectSameRender((context) {
        context.newSynth().toDestination()
          ..triggerAttackRelease('C5', 0.002, delay: 0.1)
          ..triggerAttackRelease('D5', 0.05, delay: 0.5)
          ..triggerAttackRelease('E5', 0.3, delay: 0.502);
      });
    });
    test('note names and durations', () async {
      await expectSameRender((context) {
        var synth = context.newSynth().toDestination();
        var delay = 0.1;
        for (var (note, duration) in [
          ('Bb3', '8n.'),
          ('F#4', '8t'),
          ('Db5', '16n'),
          ('440', 0.1),
          ('B#3', '32n'),
          ('Cb5', '0.2'),
        ]) {
          synth.triggerAttackRelease(note, duration, delay: delay);
          delay += 0.3;
        }
      }, duration: 3);
    });
    test('2 synths', () async {
      await expectSameRender((context) {
        context.newSynth().toDestination().triggerAttackRelease(
          'C4',
          1,
          delay: 0.1,
        );
        context.newSynth().toDestination().triggerAttackRelease(
          'E4',
          1,
          delay: 0.2,
        );
      });
    });
  });

  group('sampler', () {
    test('same pitch', () async {
      await expectSameRender((context) async {
        var sampler = (await context.createSampler({
          'C4': _c4Url,
        })).toDestination();
        sampler.triggerAttackRelease('C4', 0.5, delay: 0.1);
      });
    });
    test('pitch shift', () async {
      await expectSameRender((context) async {
        var sampler = (await context.createSampler({
          'C4': _c4Url,
        })).toDestination();
        sampler
          ..triggerAttackRelease('E4', 0.5, delay: 0.1)
          ..triggerAttackRelease('Bb3', 0.5, delay: 0.3)
          ..triggerAttackRelease('C5', 0.5, delay: 0.6)
          ..triggerAttackRelease('F2', 0.5, delay: 0.9);
      });
    });
    test('closest sample', () async {
      await expectSameRender((context) async {
        var sampler = (await context.createSampler({
          'C4': _c4Url,
          'E4': _e4Url,
          'A4': _a4Url,
        })).toDestination();
        var delay = 0.1;
        // D4 is at the same distance of C4 and E4, E4 is used.
        for (var note in ['D4', 'C#4', 'F4', 'G4', 'G#4', 'B4', 'A2', 'C6']) {
          sampler.triggerAttackRelease(note, 0.2, delay: delay);
          delay += 0.2;
        }
      });
    });
    test('chords (web player)', () async {
      await expectSameRender((context) async {
        var sampler = (await context.createSampler({
          'A3': _a4Url,
          'D4': _c4Url,
          'G4': _e4Url,
        })).toDestination();
        var time = 0.1;
        for (var note in ['E3', 'A3', 'D4', 'G4', 'B4', 'E5']) {
          sampler.triggerAttackRelease(note, 1.0, delay: time);
          time += 0.1;
        }
      }, duration: 3);
    });
    test('same note released', () async {
      await expectSameRender((context) async {
        var sampler = (await context.createSampler({
          'C4': _c4Url,
        })).toDestination();
        sampler
          ..triggerAttack('C4', delay: 0.1)
          ..triggerAttack('C4', delay: 0.3)
          // Release both
          ..triggerRelease('C4', delay: 0.5)
          // Nothing to release
          ..triggerRelease('D4', delay: 0.6)
          // Not released, plays until the end of the sample
          ..triggerAttack('G4', delay: 0.7);
      }, duration: 2.5);
    });
    test('midi keys and baseUrl', () async {
      const prefix = 'data:audio/wav;base64,';
      await expectSameRender((context) async {
        var sampler = (await context.createSampler({
          '60': _c4Url.substring(prefix.length),
          '69': _a4Url.substring(prefix.length),
        }, baseUrl: prefix)).toDestination();
        sampler
          ..triggerAttackRelease('D4', '8n', delay: 0.1)
          ..triggerAttackRelease('A4', '8n', delay: 0.4);
      });
    });
    test('audio files', () async {
      await expectSameRender((context) async {
        var sampler = (await context.createSampler({
          'C4': '../example/audio/C4[.mp3|.ogg]',
        })).toDestination();
        sampler
          ..triggerAttack('C4', delay: 0.1)
          ..triggerAttackRelease('Eb4', 0.3, delay: 0.5)
          ..triggerAttackRelease('G3', 0.4, delay: 0.7);
      });
    });
  });

  group('envelope', () {
    // Compares the automation model with a Tone.js Envelope
    test('getValueAtTime', () {
      var envelopeJs = toneJsNew(
        'Envelope',
        {'attack': 0.005, 'decay': 0.1, 'sustain': 0.3, 'release': 1}.jsify(),
      );
      var envelope = ToneEnvelope(
        ToneParam(
          const ToneAudioParamSinkNone(),
          initialValue: 1,
          sampleTime: 1 / toneJsSampleRate,
          value: 0,
        ),
      );
      void attack(double time, [double velocity = 1]) {
        toneJsCall<JSAny?>(
          envelopeJs,
          'triggerAttack',
          time.toJS,
          velocity.toJS,
        );
        envelope.triggerAttack(time, velocity);
      }

      void release(double time) {
        toneJsCall<JSAny?>(envelopeJs, 'triggerRelease', time.toJS);
        envelope.triggerRelease(time);
      }

      attack(1);
      release(1.3);
      // during the release
      attack(1.8, 0.8);
      // during the decay
      attack(1.85);
      release(1.855);
      // during the attack
      attack(3);
      attack(3.002, 0.5);
      release(3.01);
      release(3.5);
      for (var i = 0; i <= 6000; i++) {
        var time = i / 1000;
        var expected = toneJsCall<JSNumber>(
          envelopeJs,
          'getValueAtTime',
          time.toJS,
        ).toDartDouble;
        expect(
          envelope.getValueAtTime(time),
          closeTo(expected, 1e-12),
          reason: 'at $time',
        );
      }
    });
  });

  group('expressions', () {
    test('time', () {
      var converter = ToneTimeConverter(sampleRate: toneJsSampleRate);
      for (var expression in [
        '1',
        '0.5',
        '2.25',
        '1n',
        '2n',
        '4n',
        '8n',
        '16n',
        '32n',
        '4n.',
        '8n.',
        '1m',
        '2m',
        '4t',
        '8t',
        '16t',
        '192i',
        '48i',
        '2hz',
        '0.5hz',
        '1.5s',
        '1:0:0',
        '0:2:0',
        '0:0:2',
        '1:2:3',
        '1:2',
        '4410samples',
        '-1',
        '1e-3',
        ' 4n ',
      ]) {
        var expected = toneJsCall<JSNumber>(
          toneJsCall<JSObject>(toneJsGlobal, 'Time', expression.toJS),
          'toSeconds',
        ).toDartDouble;
        expect(
          converter.toSeconds(expression),
          closeTo(expected, 1e-12),
          reason: expression,
        );
      }
    });
    test('frequency', () {
      for (var expression in [
        'C4',
        'A4',
        'a4',
        'C#4',
        'Db4',
        'Cb4',
        'B#3',
        'Cx4',
        'Dbb4',
        'Bb3',
        'F#5',
        'E-1',
        'C-1',
        'G9',
        '440',
        '261.5',
        '440hz',
        '4n',
        '1m',
      ]) {
        var frequencyJs = toneJsCall<JSObject>(
          toneJsGlobal,
          'Frequency',
          expression.toJS,
        );
        var expected = toneJsCall<JSNumber>(
          frequencyJs,
          'toFrequency',
        ).toDartDouble;
        expect(
          toneTimeConverter.toFrequency(expression),
          closeTo(expected, expected * 1e-12),
          reason: expression,
        );
        var expectedMidi = toneJsCall<JSNumber>(
          frequencyJs,
          'toMidi',
        ).toDartInt;
        expect(
          toneTimeConverter.toMidi(expression),
          expectedMidi,
          reason: expression,
        );
      }
    });
  });
}
