import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import '../common/tone_param.dart';

bool? _cancelAndHoldSupported;

/// Drives a native [web.AudioParam].
class ToneWebAudioParamSink implements ToneAudioParamSink {
  /// The native param.
  final web.AudioParam param;

  /// Drives a native [web.AudioParam].
  ToneWebAudioParamSink(this.param);

  @override
  void cancelAndHoldAtTime(double time) {
    // Missing in Firefox. Tone.js only calls it when the last event is at
    // [time] and always sets the value at [time] right after, so skipping it
    // gives the same automation.
    if (_cancelAndHoldSupported ??= param.has('cancelAndHoldAtTime')) {
      param.cancelAndHoldAtTime(time);
    }
  }

  @override
  void cancelScheduledValues(double time) {
    param.cancelScheduledValues(time);
  }

  @override
  void exponentialRampToValueAtTime(double value, double time) {
    param.exponentialRampToValueAtTime(value, time);
  }

  @override
  void linearRampToValueAtTime(double value, double time) {
    param.linearRampToValueAtTime(value, time);
  }

  @override
  void setTargetAtTime(double value, double time, double timeConstant) {
    param.setTargetAtTime(value, time, timeConstant);
  }

  @override
  void setValueAtTime(double value, double time) {
    param.setValueAtTime(value, time);
  }
}
