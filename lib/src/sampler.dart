import 'dart:js_interop';

import 'package:tekartik_tone_js/src/tone_utils_js.dart';

import 'instrument.dart';
import 'js_interop.dart' as tonejs;

extension SampleExt on Sampler {
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

extension SamplePrvExt on Sampler {
  tonejs.SamplerJs get samplerJs => instrumentJs as tonejs.SamplerJs;
}

class Sampler extends Instrument {
  Sampler.fromNativeInstance(tonejs.SamplerJs super.samplerJs);

  @Deprecated('Use toDestination')
  Sampler toMaster() {
    return toDestination();
  }

  Sampler toDestination() {
    return Sampler.fromNativeInstance(samplerJs.toDestination());
  }
}
