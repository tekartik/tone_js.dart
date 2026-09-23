/// Port of Tone.js 14.7.77 `Synth` (instrument/Synth.ts, Monophonic.ts and
/// the `Source`/`Oscillator` start/stop logic).
library;

import 'dart:math';

import 'package:web/web.dart' as web;

import '../api/tone_api.dart';
import '../common/tone_envelope.dart';
import '../common/tone_param.dart';
import '../common/tone_timeline.dart';
import 'tone_web_context.dart';
import 'tone_web_source.dart';

/// Triangle oscillator through an amplitude envelope (attack 0.005,
/// decay 0.1, sustain 0.3, release 1).
class ToneWebSynthImpl implements ToneSynthApi {
  /// The context.
  final ToneWebContextImpl context;

  /// Oscillator type.
  final String oscillatorType;

  /// Instrument output.
  final web.GainNode output;

  /// Amplitude envelope node.
  final web.GainNode _envelopeNode;

  /// Amplitude envelope.
  late final ToneEnvelope envelope;

  /// Frequency signal, connected to each oscillator frequency.
  final web.ConstantSourceNode _frequencySignal;

  /// Frequency automation.
  late final ToneParam frequency;

  /// Oscillator source state.
  final _state = ToneStateTimeline();

  ToneWebOscillatorNode? _oscillator;

  /// Synth.
  ToneWebSynthImpl(this.context, {this.oscillatorType = 'triangle'})
    : output = context.audioContext.createGain(),
      _envelopeNode = context.audioContext.createGain(),
      _frequencySignal = context.audioContext.createConstantSource() {
    envelope = ToneEnvelope(context.newParam(_envelopeNode.gain, value: 0));
    _envelopeNode.connect(output);
    frequency = context.newParam(_frequencySignal.offset, value: 440);
    _frequencySignal.start(0);
  }

  @override
  ToneWebSynthImpl toDestination() {
    output.connect(context.destination);
    return this;
  }

  @override
  void triggerAttack(String note, {Object? delay}) {
    context.ensureRunning();
    var frequency = context.noteToFrequency(note);
    attackAt(frequency, context.delayToTime(delay));
  }

  @override
  void triggerRelease({Object? delay}) {
    context.ensureRunning();
    releaseAt(context.delayToTime(delay));
  }

  @override
  void triggerAttackRelease(String note, Object duration, {Object? delay}) {
    context.ensureRunning();
    var frequency = context.noteToFrequency(note);
    var time = context.delayToTime(delay);
    var computedDuration = context.durationToSeconds(duration);
    attackAt(frequency, time);
    releaseAt(time + computedDuration);
  }

  /// Starts playing [frequencyValue] at [time].
  void attackAt(double frequencyValue, double time, [double velocity = 1]) {
    envelope.triggerAttack(time, velocity);
    _startOscillator(time);
    // if there is no release portion, stop the oscillator
    if (envelope.sustain == 0) {
      _stopOscillator(time + envelope.attack + envelope.decay);
    }
    // setNote (no portamento)
    frequency.setValueAtTime(frequencyValue, time);
  }

  /// Releases at [time].
  void releaseAt(double time) {
    envelope.triggerRelease(time);
    _stopOscillator(time + envelope.release);
  }

  /// Envelope level at [time].
  double getLevelAtTime(double time) => envelope.getValueAtTime(time);

  void _startOscillator(double time) {
    var computedTime = max(time, context.currentTime);
    if (_state.getValueAtTime(computedTime) == ToneSourceState.started) {
      // restart: keep the current oscillator and cancel its scheduled stop
      _state.cancel(computedTime);
      _oscillator?.cancelStop();
    } else {
      _state.setStateAtTime(ToneSourceState.started, computedTime);
      var oscillator = ToneWebOscillatorNode(context, type: oscillatorType);
      _oscillator = oscillator;
      oscillator.connect(_envelopeNode);
      oscillator.connectFrequency(_frequencySignal);
      oscillator.start(computedTime);
    }
  }

  void _stopOscillator(double time) {
    var computedTime = max(time, context.currentTime);
    if (_state.getValueAtTime(computedTime) == ToneSourceState.started ||
        _state.getNextState(ToneSourceState.started, computedTime) != null) {
      _oscillator?.stop(computedTime);
      _state.cancel(computedTime);
      _state.setStateAtTime(ToneSourceState.stopped, computedTime);
    }
  }
}
