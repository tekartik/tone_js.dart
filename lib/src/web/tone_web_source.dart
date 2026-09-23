/// Port of Tone.js 14.7.77 `OneShotSource`, `ToneOscillatorNode` and
/// `ToneBufferSource` (source/OneShotSource.ts, source/oscillator/,
/// source/buffer/).
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:math';

import 'package:web/web.dart' as web;

import '../common/tone_envelope.dart';
import '../common/tone_param.dart';
import '../common/tone_timeline.dart';
import 'tone_web_context.dart';

/// A source played once, with a gain envelope to fade in/out and stop.
abstract class ToneWebOneShotSource {
  /// The context.
  final ToneWebContextImpl context;

  /// Output node, its gain is the fade in/out envelope.
  final web.GainNode gainNode;

  /// Output gain automation.
  late final ToneParam gain;

  /// Fade in time.
  final double fadeIn;

  /// Fade out time.
  final double fadeOut;

  /// Fade curve.
  final ToneEnvelopeCurve curve;

  /// Start time, -1 if not started.
  var startTime = -1.0;

  /// Stop time (end of fade out), -1 if not stopped.
  var stopTime = -1.0;

  Timer? _timeout;

  /// Called once when ended.
  void Function()? onended;

  /// A source played once.
  ToneWebOneShotSource(
    this.context, {
    this.fadeIn = 0,
    this.fadeOut = 0,
    this.curve = ToneEnvelopeCurve.linear,
  }) : gainNode = context.audioContext.createGain() {
    gain = context.newParam(gainNode.gain, value: 0);
  }

  /// Connects the output.
  void connect(web.AudioNode destination) {
    gainNode.connect(destination);
  }

  /// Schedules the fade in.
  void startGain(double time, [double gainValue = 1]) {
    if (startTime != -1) {
      throw StateError('Source cannot be started more than once');
    }
    startTime = max(time + fadeIn, context.currentTime);
    if (fadeIn > 0) {
      gain.setValueAtTime(0, time);
      if (curve == ToneEnvelopeCurve.linear) {
        gain.linearRampToValueAtTime(gainValue, time + fadeIn);
      } else {
        gain.exponentialApproachValueAtTime(gainValue, time, fadeIn);
      }
    } else {
      gain.setValueAtTime(gainValue, time);
    }
  }

  /// Stops (fade out) at [time].
  void stop(double time) {
    if (startTime == -1) {
      throw StateError("'start' must be called before 'stop'");
    }
    cancelStop();
    stopTime = max(time + fadeOut, context.currentTime);
    if (fadeOut > 0) {
      if (curve == ToneEnvelopeCurve.linear) {
        gain.linearRampTo(0, fadeOut, time);
      } else {
        gain.targetRampTo(0, fadeOut, time);
      }
    } else {
      gain.cancelAndHoldAtTime(time);
      gain.setValueAtTime(0, time);
    }
    _timeout = context.newTimer(stopTime, () {
      // allow additional time for the exponential curve to fully decay
      var additionalTail = curve == ToneEnvelopeCurve.exponential
          ? fadeOut * 2
          : 0;
      stopSource(context.now() + additionalTail);
      handleEnded();
    });
  }

  /// Cancels a scheduled stop.
  void cancelStop() {
    if (startTime == -1) {
      throw StateError('Source is not started');
    }
    gain.cancelScheduledValues(startTime + context.sampleTime);
    _timeout?.cancel();
    _timeout = null;
    stopTime = -1;
  }

  /// Stops the native source at [time] (now if null).
  void stopSource([double? time]);

  /// Calls [onended] once.
  void handleEnded() {
    var callback = onended;
    if (callback != null) {
      onended = null;
      callback();
    }
  }
}

/// Oscillator played once.
class ToneWebOscillatorNode extends ToneWebOneShotSource {
  /// The native oscillator.
  final web.OscillatorNode oscillator;

  web.AudioNode? _frequencySignal;

  /// Oscillator played once.
  ToneWebOscillatorNode(super.context, {String type = 'sine'})
    : oscillator = context.audioContext.createOscillator() {
    oscillator.type = type;
    oscillator.connect(gainNode);
    oscillator.onended = ((web.Event _) {
      _frequencySignal?.disconnect(oscillator.frequency);
      oscillator.disconnect();
      gainNode.disconnect();
      handleEnded();
    }).toJS;
  }

  /// Drives the frequency with [signal] (like a Tone.js signal connection,
  /// the param value is set to 0).
  void connectFrequency(web.AudioNode signal) {
    var frequency = oscillator.frequency;
    frequency.cancelScheduledValues(0);
    frequency.setValueAtTime(0, 0);
    signal.connect(frequency);
    _frequencySignal = signal;
  }

  /// Starts at [time].
  void start(double time) {
    startGain(time);
    oscillator.start(time);
  }

  @override
  void stopSource([double? time]) {
    oscillator.stop(time ?? context.now());
  }
}

/// Audio buffer played once.
class ToneWebBufferSource extends ToneWebOneShotSource {
  /// The native source.
  final web.AudioBufferSourceNode source;

  /// The buffer played.
  final web.AudioBuffer buffer;

  var _sourceStarted = false;
  var _sourceStopped = false;

  /// Audio buffer played once.
  ToneWebBufferSource(
    super.context,
    this.buffer, {
    double playbackRate = 1,
    super.fadeIn,
    super.fadeOut,
    super.curve,
  }) : source = context.audioContext.createBufferSource() {
    source.connect(gainNode);
    source.onended = ((web.Event _) {
      stopSource();
      source.disconnect();
      gainNode.disconnect();
    }).toJS;
    context.newParam(source.playbackRate, value: playbackRate);
  }

  /// Starts at [time] from [offset], stops after [duration] if specified.
  void start(
    double time, {
    double offset = 0,
    double? duration,
    double gainValue = 1,
  }) {
    startGain(time, gainValue);
    var computedOffset = max(offset, 0.0);
    source.buffer = buffer;
    source.loopEnd = buffer.duration;
    if (toneLT(computedOffset, buffer.duration)) {
      _sourceStarted = true;
      source.start(time, computedOffset);
    }
    if (duration != null) {
      stop(time + max(duration, 0.0));
    }
  }

  @override
  void stopSource([double? time]) {
    if (!_sourceStopped && _sourceStarted) {
      _sourceStopped = true;
      source.stop(time ?? context.now());
      handleEnded();
    }
  }
}
