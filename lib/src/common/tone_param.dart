/// Port of Tone.js 14.7.77 `Param` automation (core/context/Param.ts).
///
/// Tone.js keeps its own copy of the scheduled automation to compute the
/// value at a given time (used by envelopes and fades); the native
/// `AudioParam` is driven through a [ToneAudioParamSink].
library;

import 'dart:math';

import 'tone_timeline.dart';

/// Automation event type.
enum ToneAutomationType {
  /// setValueAtTime
  setValueAtTime,

  /// linearRampToValueAtTime
  linearRampToValueAtTime,

  /// exponentialRampToValueAtTime
  exponentialRampToValueAtTime,

  /// setTargetAtTime
  setTargetAtTime,
}

/// Automation event.
class ToneAutomationEvent implements ToneTimelineEvent {
  /// Type.
  final ToneAutomationType type;
  @override
  final double time;

  /// Target value.
  final double value;

  /// Time constant, only for [ToneAutomationType.setTargetAtTime].
  final double constant;

  /// Automation event.
  ToneAutomationEvent(this.type, this.time, this.value, {this.constant = 0});

  @override
  String toString() =>
      '${type.name}($value, $time${type == ToneAutomationType.setTargetAtTime ? ', $constant' : ''})';
}

/// The native (Web Audio) parameter being automated.
abstract interface class ToneAudioParamSink {
  /// AudioParam.setValueAtTime
  void setValueAtTime(double value, double time);

  /// AudioParam.linearRampToValueAtTime
  void linearRampToValueAtTime(double value, double time);

  /// AudioParam.exponentialRampToValueAtTime
  void exponentialRampToValueAtTime(double value, double time);

  /// AudioParam.setTargetAtTime
  void setTargetAtTime(double value, double time, double timeConstant);

  /// AudioParam.cancelScheduledValues
  void cancelScheduledValues(double time);

  /// AudioParam.cancelAndHoldAtTime
  void cancelAndHoldAtTime(double time);
}

/// Automated parameter (values are native values, no unit conversion).
class ToneParam {
  /// Minimum output value, used instead of 0 for ramps.
  static const minOutput = 1e-7;

  final ToneAudioParamSink _param;

  /// Native default value, used before any event.
  final double initialValue;

  /// 1 / sampleRate.
  final double sampleTime;

  final _events = ToneTimeline<ToneAutomationEvent>(memory: 1000);

  /// Tone.js set the [value] at time 0 if it differs from [initialValue].
  ToneParam(
    this._param, {
    required this.initialValue,
    required this.sampleTime,
    double? value,
  }) {
    if (value != null && value != initialValue) {
      setValueAtTime(value, 0);
    }
  }

  /// Scheduled events (for debugging and tests).
  List<ToneAutomationEvent> get events => _events.events;

  void _checkFinite(String method, double value, double time) {
    if (!value.isFinite || !time.isFinite) {
      throw ArgumentError('Invalid argument(s) to $method: $value, $time');
    }
  }

  /// Schedule a value change.
  void setValueAtTime(double value, double time) {
    _checkFinite('setValueAtTime', value, time);
    _events.add(
      ToneAutomationEvent(ToneAutomationType.setValueAtTime, time, value),
    );
    _param.setValueAtTime(value, time);
  }

  /// Value at [time] according to the scheduled events.
  double getValueAtTime(double time) {
    var computedTime = max(time, 0.0);
    var after = _events.getAfter(computedTime);
    var before = _events.get(computedTime);
    var value = initialValue;
    if (before == null) {
      value = initialValue;
    } else if (before.type == ToneAutomationType.setTargetAtTime &&
        (after == null || after.type == ToneAutomationType.setValueAtTime)) {
      var previous = _events.getBefore(before.time);
      var previousVal = previous?.value ?? initialValue;
      value = _exponentialApproach(
        before.time,
        previousVal,
        before.value,
        before.constant,
        computedTime,
      );
    } else if (after == null) {
      value = before.value;
    } else if (after.type == ToneAutomationType.linearRampToValueAtTime ||
        after.type == ToneAutomationType.exponentialRampToValueAtTime) {
      var beforeValue = before.value;
      if (before.type == ToneAutomationType.setTargetAtTime) {
        var previous = _events.getBefore(before.time);
        beforeValue = previous?.value ?? initialValue;
      }
      if (after.type == ToneAutomationType.linearRampToValueAtTime) {
        value = _linearInterpolate(
          before.time,
          beforeValue,
          after.time,
          after.value,
          computedTime,
        );
      } else {
        value = _exponentialInterpolate(
          before.time,
          beforeValue,
          after.time,
          after.value,
          computedTime,
        );
      }
    } else {
      value = before.value;
    }
    return value;
  }

  /// Creates a schedule point with the current value at [time].
  void setRampPoint(double time) {
    var currentVal = getValueAtTime(time);
    cancelAndHoldAtTime(time);
    if (currentVal == 0) {
      currentVal = minOutput;
    }
    setValueAtTime(currentVal, time);
  }

  /// Linear ramp ending at [endTime].
  void linearRampToValueAtTime(double value, double endTime) {
    _checkFinite('linearRampToValueAtTime', value, endTime);
    _events.add(
      ToneAutomationEvent(
        ToneAutomationType.linearRampToValueAtTime,
        endTime,
        value,
      ),
    );
    _param.linearRampToValueAtTime(value, endTime);
  }

  /// Exponential ramp ending at [endTime].
  void exponentialRampToValueAtTime(double value, double endTime) {
    // the value can't be 0
    var numericValue = toneEQ(value, 0) ? minOutput : value;
    _checkFinite('exponentialRampToValueAtTime', numericValue, endTime);
    _events.add(
      ToneAutomationEvent(
        ToneAutomationType.exponentialRampToValueAtTime,
        endTime,
        numericValue,
      ),
    );
    _param.exponentialRampToValueAtTime(numericValue, endTime);
  }

  /// Exponential ramp from the value at [startTime] over [rampTime].
  void exponentialRampTo(double value, double rampTime, double startTime) {
    setRampPoint(startTime);
    exponentialRampToValueAtTime(value, startTime + rampTime);
  }

  /// Linear ramp from the value at [startTime] over [rampTime].
  void linearRampTo(double value, double rampTime, double startTime) {
    setRampPoint(startTime);
    linearRampToValueAtTime(value, startTime + rampTime);
  }

  /// Exponential approach from the value at [startTime] over [rampTime].
  void targetRampTo(double value, double rampTime, double startTime) {
    setRampPoint(startTime);
    exponentialApproachValueAtTime(value, startTime, rampTime);
  }

  /// setTargetAtTime reaching (almost) [value] at [time] + [rampTime], ends
  /// with a linear ramp at 90%.
  void exponentialApproachValueAtTime(
    double value,
    double time,
    double rampTime,
  ) {
    var timeConstant = log(rampTime + 1) / log(200);
    setTargetAtTime(value, time, timeConstant);
    // at 90% start a linear ramp to the final value
    cancelAndHoldAtTime(time + rampTime * 0.9);
    linearRampToValueAtTime(value, time + rampTime);
  }

  /// Exponential approach toward [value].
  void setTargetAtTime(double value, double startTime, double timeConstant) {
    if (!timeConstant.isFinite || timeConstant <= 0) {
      throw ArgumentError('timeConstant must be a number greater than 0');
    }
    _checkFinite('setTargetAtTime', value, startTime);
    _events.add(
      ToneAutomationEvent(
        ToneAutomationType.setTargetAtTime,
        startTime,
        value,
        constant: timeConstant,
      ),
    );
    _param.setTargetAtTime(value, startTime, timeConstant);
  }

  /// Cancel the events at and after [time].
  void cancelScheduledValues(double time) {
    if (!time.isFinite) {
      throw ArgumentError('Invalid argument to cancelScheduledValues: $time');
    }
    _events.cancel(time);
    _param.cancelScheduledValues(time);
  }

  /// Cancel the events after [time] keeping the value at [time].
  void cancelAndHoldAtTime(double time) {
    if (!time.isFinite) {
      throw ArgumentError('Invalid argument to cancelAndHoldAtTime: $time');
    }
    var valueAtTime = getValueAtTime(time);
    var before = _events.get(time);
    var after = _events.getAfter(time);
    if (before != null && toneEQ(before.time, time)) {
      // remove everything after
      if (after != null) {
        _param.cancelScheduledValues(after.time);
        _events.cancel(after.time);
      } else {
        _param.cancelAndHoldAtTime(time);
        _events.cancel(time + sampleTime);
      }
    } else if (after != null) {
      _param.cancelScheduledValues(after.time);
      // cancel the next event(s)
      _events.cancel(after.time);
      if (after.type == ToneAutomationType.linearRampToValueAtTime) {
        linearRampToValueAtTime(valueAtTime, time);
      } else if (after.type ==
          ToneAutomationType.exponentialRampToValueAtTime) {
        exponentialRampToValueAtTime(valueAtTime, time);
      }
    }
    // set the value at the given time
    _events.add(
      ToneAutomationEvent(ToneAutomationType.setValueAtTime, time, valueAtTime),
    );
    _param.setValueAtTime(valueAtTime, time);
  }

  double _exponentialApproach(
    double t0,
    double v0,
    double v1,
    double timeConstant,
    double t,
  ) => v1 + (v0 - v1) * exp(-(t - t0) / timeConstant);

  double _linearInterpolate(
    double t0,
    double v0,
    double t1,
    double v1,
    double t,
  ) => v0 + (v1 - v0) * ((t - t0) / (t1 - t0));

  double _exponentialInterpolate(
    double t0,
    double v0,
    double t1,
    double v1,
    double t,
  ) => v0 * pow(v1 / v0, (t - t0) / (t1 - t0));
}

/// Sink doing nothing, when only the computed values are needed.
class ToneAudioParamSinkNone implements ToneAudioParamSink {
  /// Sink doing nothing.
  const ToneAudioParamSinkNone();

  @override
  void cancelAndHoldAtTime(double time) {}

  @override
  void cancelScheduledValues(double time) {}

  @override
  void exponentialRampToValueAtTime(double value, double time) {}

  @override
  void linearRampToValueAtTime(double value, double time) {}

  @override
  void setTargetAtTime(double value, double time, double timeConstant) {}

  @override
  void setValueAtTime(double value, double time) {}
}
