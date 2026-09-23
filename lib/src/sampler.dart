import 'dart:js_interop';

import 'package:tekartik_tone_js/src/tone_utils_js.dart';

import 'api/tone_api.dart';
import 'instrument.dart';
import 'js_interop.dart' as tonejs;

/// Kept for compatibility, the methods are now [Sampler] members.
extension SampleExt on Sampler {
  /// See [Sampler.triggerAttack].
  void triggerAttack(String note, {Object? delay}) =>
      this.triggerAttack(note, delay: delay);

  /// See [Sampler.triggerAttackRelease].
  void triggerAttackRelease(String note, Object duration, {Object? delay}) =>
      this.triggerAttackRelease(note, duration, delay: delay);
}

extension SamplePrvExt on Sampler {
  tonejs.SamplerJs get samplerJs => instrumentJs as tonejs.SamplerJs;
}

class Sampler extends Instrument implements ToneSamplerApi {
  Sampler.fromNativeInstance(tonejs.SamplerJs super.samplerJs);

  // @Deprecated('Use toDestination')
  Sampler toMaster() {
    return toDestination();
  }

  @override
  Sampler toDestination() {
    return Sampler.fromNativeInstance(samplerJs.toDestination());
  }

  @override
  void triggerAttack(String note, {Object? delay}) {
    JSAny? timeJs;
    if (delay != null) {
      timeJs = delayToJs(delay);
    }
    if (timeJs == null) {
      //nativeInstance.triggerAttack(note);
      samplerJs.triggerAttack(note.toJS);
    } else {
      samplerJs.triggerAttack(note.toJS, timeJs);
      //nativeInstance.triggerAttack(note, time);
    }
  }

  @override
  void triggerRelease(String note, {Object? delay}) {
    if (delay == null) {
      samplerJs.triggerRelease(note.toJS);
    } else {
      samplerJs.triggerRelease(note.toJS, delayToJs(delay));
    }
  }

  @override
  void triggerAttackRelease(String note, Object duration, {Object? delay}) {
    JSAny? timeJs;
    if (delay != null) {
      timeJs = delayToJs(delay);
    }
    if (timeJs == null) {
      // _nativeInstance.triggerAttackRelease(note, duration);
      samplerJs.triggerAttackRelease(note.toJS, durationToJs(duration));
    } else {
      samplerJs.triggerAttackRelease(note.toJS, durationToJs(duration), timeJs);
    }
  }
}
