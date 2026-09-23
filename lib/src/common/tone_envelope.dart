/// Port of Tone.js 14.7.77 `Envelope` (component/envelope/Envelope.ts).
library;

import 'tone_param.dart';

/// Envelope curve (Tone.js array curves are not supported).
enum ToneEnvelopeCurve {
  /// Linear.
  linear,

  /// Exponential.
  exponential,
}

/// ADSR envelope driving a [ToneParam] (0 to 1).
class ToneEnvelope {
  /// The automated signal.
  final ToneParam signal;

  /// Attack time in seconds.
  double attack;

  /// Decay time in seconds.
  double decay;

  /// Sustain level (0-1).
  double sustain;

  /// Release time in seconds.
  double release;

  /// Attack curve.
  ToneEnvelopeCurve attackCurve;

  /// Decay curve.
  ToneEnvelopeCurve decayCurve;

  /// Release curve.
  ToneEnvelopeCurve releaseCurve;

  /// Default values are the one of Tone.js `Synth` envelope.
  ToneEnvelope(
    this.signal, {
    this.attack = 0.005,
    this.decay = 0.1,
    this.sustain = 0.3,
    this.release = 1,
    this.attackCurve = ToneEnvelopeCurve.linear,
    this.decayCurve = ToneEnvelopeCurve.exponential,
    this.releaseCurve = ToneEnvelopeCurve.exponential,
  });

  /// Trigger the attack/decay portion at [time].
  void triggerAttack(double time, [double velocity = 1]) {
    var attack = this.attack;
    // check if it's not a complete attack
    var currentValue = getValueAtTime(time);
    if (currentValue > 0) {
      // subtract the current value from the attack time
      var attackRate = 1 / attack;
      var remainingDistance = 1 - currentValue;
      // the attack is now the remaining time
      attack = remainingDistance / attackRate;
    }
    if (attack < signal.sampleTime) {
      signal.cancelScheduledValues(time);
      // case where the attack time is 0 should set instantly
      signal.setValueAtTime(velocity, time);
    } else if (attackCurve == ToneEnvelopeCurve.linear) {
      signal.linearRampTo(velocity, attack, time);
    } else {
      signal.targetRampTo(velocity, attack, time);
    }
    // decay
    if (decay != 0 && !decay.isNaN && sustain < 1) {
      var decayValue = velocity * sustain;
      var decayStart = time + attack;
      if (decayCurve == ToneEnvelopeCurve.linear) {
        signal.linearRampToValueAtTime(decayValue, decay + decayStart);
      } else {
        signal.exponentialApproachValueAtTime(decayValue, decayStart, decay);
      }
    }
  }

  /// Trigger the release portion at [time].
  void triggerRelease(double time) {
    var currentValue = getValueAtTime(time);
    if (currentValue > 0) {
      if (release < signal.sampleTime) {
        signal.setValueAtTime(0, time);
      } else if (releaseCurve == ToneEnvelopeCurve.linear) {
        signal.linearRampTo(0, release, time);
      } else {
        signal.targetRampTo(0, release, time);
      }
    }
  }

  /// Envelope value at [time].
  double getValueAtTime(double time) => signal.getValueAtTime(time);
}
