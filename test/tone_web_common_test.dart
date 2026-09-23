/// Pure Dart parts of tone_web (Tone.js port), run on vm and browser.
library;

import 'dart:math';

import 'package:tekartik_tone_js/src/common/tone_envelope.dart';
import 'package:tekartik_tone_js/src/common/tone_param.dart';
import 'package:tekartik_tone_js/src/common/tone_sampler_utils.dart';
import 'package:tekartik_tone_js/src/common/tone_time.dart';
import 'package:tekartik_tone_js/src/common/tone_timeline.dart';
import 'package:test/test.dart';

class _Event implements ToneTimelineEvent {
  @override
  final double time;
  final String name;

  _Event(this.time, this.name);

  @override
  String toString() => name;
}

/// Records the native calls.
class _RecordingSink implements ToneAudioParamSink {
  final calls = <String>[];

  String _n(double value) => value.toStringAsPrecision(6);

  @override
  void cancelAndHoldAtTime(double time) =>
      calls.add('cancelAndHoldAtTime(${_n(time)})');

  @override
  void cancelScheduledValues(double time) =>
      calls.add('cancelScheduledValues(${_n(time)})');

  @override
  void exponentialRampToValueAtTime(double value, double time) =>
      calls.add('exponentialRampToValueAtTime(${_n(value)}, ${_n(time)})');

  @override
  void linearRampToValueAtTime(double value, double time) =>
      calls.add('linearRampToValueAtTime(${_n(value)}, ${_n(time)})');

  @override
  void setTargetAtTime(double value, double time, double timeConstant) => calls
      .add('setTargetAtTime(${_n(value)}, ${_n(time)}, ${_n(timeConstant)})');

  @override
  void setValueAtTime(double value, double time) =>
      calls.add('setValueAtTime(${_n(value)}, ${_n(time)})');
}

void main() {
  group('time', () {
    const converter = toneTimeConverter;
    test('seconds', () {
      expect(converter.toSeconds(1), 1);
      expect(converter.toSeconds(0.25), 0.25);
      expect(converter.toSeconds('1'), 1);
      expect(converter.toSeconds('1.5'), 1.5);
      expect(converter.toSeconds('1.5s'), 1.5);
      expect(converter.toSeconds(' 2 '), 2);
      expect(converter.toSeconds('-1'), -1);
      expect(converter.toSeconds('1e-3'), 0.001);
    });
    test('notation', () {
      // 120 bpm, 4/4
      expect(converter.toSeconds('1n'), 2);
      expect(converter.toSeconds('2n'), 1);
      expect(converter.toSeconds('4n'), 0.5);
      expect(converter.toSeconds('8n'), 0.25);
      expect(converter.toSeconds('4n.'), 0.75);
      expect(converter.toSeconds('1m'), 2);
      expect(converter.toSeconds('2m'), 4);
      expect(converter.toSeconds('8t'), closeTo(1 / 6, 1e-12));
      expect(converter.toSeconds('4t'), closeTo(1 / 3, 1e-12));
      expect(converter.toSeconds('192i'), 0.5);
      expect(converter.toSeconds('1:2:2'), 3.25);
      expect(converter.toSeconds('0:1'), 0.5);
      expect(converter.toSeconds('2hz'), 0.5);
      expect(converter.toSeconds('4410samples'), 0.1);
      expect(
        const ToneTimeConverter(bpm: 60).toSeconds('4n'),
        1,
        reason: 'bpm',
      );
    });
    test('relative', () {
      expect(converter.toSeconds('+1', now: 10), 11);
      expect(converter.toSeconds('+4n', now: 10), 10.5);
    });
    test('invalid', () {
      expect(() => converter.toSeconds('dummy'), throwsArgumentError);
      expect(() => converter.toSeconds(true), throwsArgumentError);
    });
  });

  group('frequency', () {
    const converter = toneTimeConverter;
    test('notes', () {
      expect(converter.toFrequency('A4'), 440);
      expect(converter.toFrequency('a4'), 440);
      expect(converter.toFrequency('A5'), 880);
      expect(converter.toFrequency('C4'), closeTo(261.6255653005986, 1e-9));
      expect(converter.toFrequency('C#4'), converter.toFrequency('Db4'));
      expect(converter.toFrequency('B#3'), converter.toFrequency('C4'));
      expect(converter.toFrequency('Cb4'), converter.toFrequency('B3'));
      expect(converter.toFrequency('Cx4'), converter.toFrequency('D4'));
      expect(converter.toFrequency('Ebb4'), converter.toFrequency('D4'));
      expect(converter.toFrequency('Bbb3'), converter.toFrequency('A3'));
      expect(converter.toFrequency('C-1'), closeTo(toneMtof(0), 1e-9));
    });
    test('numbers', () {
      expect(converter.toFrequency(440), 440);
      expect(converter.toFrequency('440'), 440);
      expect(converter.toFrequency('440hz'), 440);
      expect(converter.toFrequency('69midi'), 440);
      expect(converter.toFrequency('4n'), 2);
    });
    test('midi', () {
      expect(converter.toMidi('C4'), 60);
      expect(converter.toMidi('A4'), 69);
      expect(converter.toMidi('C-1'), 0);
      expect(converter.toMidi('Db4'), 61);
      expect(converter.toMidi('445'), 69);
      expect(toneFtomf(toneMtof(60)), closeTo(60, 1e-9));
      expect(toneIntervalToFrequencyRatio(12), 2);
      expect(toneIntervalToFrequencyRatio(-12), 0.5);
    });
    test('invalid', () {
      expect(() => converter.toFrequency('H4'), throwsArgumentError);
    });
    test('isNote', () {
      expect(toneIsNote('C4'), isTrue);
      expect(toneIsNote('bb-1'), isTrue);
      expect(toneIsNote('60'), isFalse);
      expect(toneIsNote('H4'), isFalse);
    });
  });

  test('js helpers', () {
    expect(toneJsRound(0.5), 1);
    expect(toneJsRound(-0.5), 0);
    expect(toneJsRound(-1.5), -1);
    expect(toneJsRound(2.4), 2);
    expect(toneJsParseFloat('1.5abc'), 1.5);
    expect(toneJsParseFloat(' -2e2x'), -200);
    expect(toneJsParseFloat('.5'), 0.5);
    expect(toneJsParseFloat('abc'), isNaN);
  });

  group('sampler utils', () {
    test('key to midi', () {
      expect(toneSamplerKeyToMidi('C4'), 60);
      expect(toneSamplerKeyToMidi('A#3'), 58);
      expect(toneSamplerKeyToMidi('60'), 60);
      expect(() => toneSamplerKeyToMidi('dummy'), throwsArgumentError);
    });
    test('closest', () {
      var samples = {60, 64, 69};
      int closest(int midi) =>
          midi - toneSamplerFindClosest(midi, samples.contains);
      expect(closest(60), 60);
      expect(closest(61), 60);
      // same distance, upper sample
      expect(closest(62), 64);
      expect(closest(66), 64);
      expect(closest(67), 69);
      expect(closest(20), 60);
      expect(closest(120), 69);
      expect(() => toneSamplerFindClosest(60, (_) => false), throwsStateError);
    });
    test('url', () {
      String resolve(String url, Set<String> supported) =>
          toneResolveSampleUrl(url, supportsType: supported.contains);
      expect(resolve('C4.mp3', {'mp3'}), 'C4.mp3');
      expect(resolve('C4[.mp3|.ogg]', {'mp3', 'ogg'}), 'C4.mp3');
      expect(resolve('C4[.mp3|.ogg]', {'ogg'}), 'C4.ogg');
      expect(resolve('C4[.mp3|.ogg]', {}), 'C4.mp3');
      expect(resolve('a/b/C4[.ogg|.mp3]', {'mp3'}), 'a/b/C4.mp3');
    });
  });

  group('timeline', () {
    test('search', () {
      var timeline = ToneTimeline<_Event>();
      expect(timeline.get(0), isNull);
      timeline
        ..add(_Event(1, 'b'))
        ..add(_Event(0, 'a'))
        ..add(_Event(2, 'd'))
        ..add(_Event(1, 'c'));
      expect(timeline.events.map((e) => e.name), ['a', 'b', 'c', 'd']);
      expect(timeline.get(-1), isNull);
      expect(timeline.get(0.5)?.name, 'a');
      // last event with the same time
      expect(timeline.get(1)?.name, 'c');
      expect(timeline.get(1 + 1e-7)?.name, 'c');
      expect(timeline.get(5)?.name, 'd');
      expect(timeline.getAfter(1)?.name, 'd');
      expect(timeline.getAfter(0.5)?.name, 'b');
      expect(timeline.getAfter(2), isNull);
      expect(timeline.getBefore(1)?.name, 'b');
      expect(timeline.getBefore(3)?.name, 'd');
      expect(timeline.getBefore(0), isNull);
    });
    test('cancel', () {
      ToneTimeline<_Event> newTimeline() => ToneTimeline<_Event>()
        ..add(_Event(0, 'a'))
        ..add(_Event(1, 'b'))
        ..add(_Event(1, 'c'))
        ..add(_Event(2, 'd'));
      expect((newTimeline()..cancel(1)).events.map((e) => e.name), ['a']);
      expect((newTimeline()..cancel(1.5)).events.map((e) => e.name), [
        'a',
        'b',
        'c',
      ]);
      expect((newTimeline()..cancel(-1)).events, isEmpty);
      expect((newTimeline()..cancel(3)).length, 4);
    });
    test('memory', () {
      var timeline = ToneTimeline<_Event>(memory: 2)
        ..add(_Event(0, 'a'))
        ..add(_Event(1, 'b'))
        ..add(_Event(2, 'c'));
      expect(timeline.events.map((e) => e.name), ['b', 'c']);
    });
    test('state', () {
      var state = ToneStateTimeline();
      expect(state.getValueAtTime(0), ToneSourceState.stopped);
      state
        ..setStateAtTime(ToneSourceState.started, 1)
        ..setStateAtTime(ToneSourceState.stopped, 2);
      expect(state.getValueAtTime(0.5), ToneSourceState.stopped);
      expect(state.getValueAtTime(1.5), ToneSourceState.started);
      expect(state.getValueAtTime(2), ToneSourceState.stopped);
      expect(state.getNextState(ToneSourceState.started, 0.5)?.time, 1);
      expect(state.getNextState(ToneSourceState.started, 1.5)?.time, 1);
      expect(state.getNextState(ToneSourceState.started, 2.5), isNull);
    });
  });

  group('param', () {
    ToneParam newParam(ToneAudioParamSink sink) =>
        ToneParam(sink, initialValue: 1, sampleTime: 1 / 44100, value: 0);

    test('values', () {
      var param = newParam(const ToneAudioParamSinkNone());
      expect(param.getValueAtTime(-1), 0);
      param
        ..setValueAtTime(1, 1)
        ..linearRampToValueAtTime(2, 2)
        ..exponentialRampToValueAtTime(4, 3)
        ..setTargetAtTime(0, 4, 0.5);
      expect(param.getValueAtTime(0.5), 0);
      expect(param.getValueAtTime(1), 1);
      expect(param.getValueAtTime(1.5), 1.5);
      expect(param.getValueAtTime(2.5), closeTo(2 * sqrt(2), 1e-12));
      expect(param.getValueAtTime(3.5), 4);
      expect(param.getValueAtTime(4.5), closeTo(4 * exp(-1), 1e-12));
    });
    test('initial value', () {
      var param = ToneParam(
        const ToneAudioParamSinkNone(),
        initialValue: 440,
        sampleTime: 1 / 44100,
      );
      expect(param.events, isEmpty);
      expect(param.getValueAtTime(1), 440);
    });
    test('cancelAndHoldAtTime', () {
      var param = newParam(const ToneAudioParamSinkNone())
        ..setValueAtTime(0, 1)
        ..linearRampToValueAtTime(1, 2)
        ..cancelAndHoldAtTime(1.5);
      expect(param.getValueAtTime(1.5), closeTo(0.5, 1e-12));
      expect(param.getValueAtTime(1.75), closeTo(0.5, 1e-12));
      expect(param.getValueAtTime(3), closeTo(0.5, 1e-12));
    });
    test('invalid', () {
      var param = newParam(const ToneAudioParamSinkNone());
      expect(() => param.setValueAtTime(double.nan, 0), throwsArgumentError);
      expect(() => param.setTargetAtTime(1, 0, 0), throwsArgumentError);
    });
  });

  group('envelope', () {
    ToneEnvelope newEnvelope(ToneAudioParamSink sink) => ToneEnvelope(
      ToneParam(sink, initialValue: 1, sampleTime: 1 / 44100, value: 0),
    );
    test('native calls', () {
      var sink = _RecordingSink();
      var envelope = newEnvelope(sink)..triggerAttack(1);
      // Same calls as Tone.js Synth envelope.
      var timeConstant = log(1.1) / log(200);
      var decayHold = 0.3 + 0.7 * exp(-0.09 / timeConstant);
      expect(sink.calls, [
        'setValueAtTime(0.00000, 0.00000)',
        'setValueAtTime(0.00000, 1.00000)',
        'setValueAtTime(1.00000e-7, 1.00000)',
        'linearRampToValueAtTime(1.00000, 1.00500)',
        'setTargetAtTime(0.300000, 1.00500, ${timeConstant.toStringAsPrecision(6)})',
        'setValueAtTime(${decayHold.toStringAsPrecision(6)}, 1.09500)',
        'linearRampToValueAtTime(0.300000, 1.10500)',
      ]);
      sink.calls.clear();
      envelope.triggerRelease(2);
      var releaseTimeConstant = log(2) / log(200);
      var releaseHold = 0.3 * exp(-0.9 / releaseTimeConstant);
      expect(sink.calls, [
        'setValueAtTime(0.300000, 2.00000)',
        'setValueAtTime(0.300000, 2.00000)',
        'setTargetAtTime(0.00000, 2.00000, ${releaseTimeConstant.toStringAsPrecision(6)})',
        'setValueAtTime(${releaseHold.toStringAsPrecision(6)}, 2.90000)',
        'linearRampToValueAtTime(0.00000, 3.00000)',
      ]);
    });
    test('values', () {
      var envelope = newEnvelope(const ToneAudioParamSinkNone())
        ..triggerAttack(1)
        ..triggerRelease(2);
      expect(envelope.getValueAtTime(0.5), 0);
      expect(envelope.getValueAtTime(1.0025), closeTo(0.5, 1e-6));
      expect(envelope.getValueAtTime(1.005), closeTo(1, 1e-12));
      expect(envelope.getValueAtTime(1.2), closeTo(0.3, 1e-12));
      expect(envelope.getValueAtTime(2), closeTo(0.3, 1e-12));
      expect(envelope.getValueAtTime(2.1), inExclusiveRange(0.01, 0.3));
      expect(envelope.getValueAtTime(3), 0);
    });
    test('retrigger', () {
      var envelope = newEnvelope(const ToneAudioParamSinkNone())
        ..triggerAttack(1)
        ..triggerRelease(1.5);
      var value = envelope.getValueAtTime(1.6);
      expect(value, inExclusiveRange(0, 0.3));
      // partial attack from the current value, same attack rate
      envelope.triggerAttack(1.6);
      expect(envelope.getValueAtTime(1.6), closeTo(value, 1e-12));
      expect(
        envelope.getValueAtTime(1.6 + 0.005 * (1 - value)),
        closeTo(1, 1e-12),
      );
      expect(envelope.getValueAtTime(2.5), closeTo(0.3, 1e-12));
    });
  });
}
