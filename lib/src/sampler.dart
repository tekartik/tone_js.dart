import 'dart:js_interop';

import 'package:js/js_util.dart' as js;
import 'package:tekartik_tone_js/src/tone_utils_js.dart';

import 'instrument.dart';
import 'js_interop.dart' as tonejs;
import 'js_interop_compat.dart' as tone_js;
import 'tone.dart';

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
  tone_js.Sampler get nativeSampler =>
      (this as Instrument).nativeInstance as tone_js.Sampler;
  tone_js.Sampler get nativeInstance => nativeSampler;
  tonejs.SamplerJs get samplerJs => instrumentJs as tonejs.SamplerJs;
}

class Sampler extends Instrument {
  Sampler.fromNativeInstance(
      tone_js.Sampler super.nativeInstance, tonejs.SamplerJs super.samplerJs);

  Sampler()
      : super(
            js.callConstructor(toneContext.nativeInstance.Synth, [])
                as tone_js.Synth,
            toneContext.toneJs.newSynth());

  @Deprecated('Use toDestination')
  Sampler toMaster() {
    return toDestination();
  }

  Sampler toDestination() {
    return Sampler.fromNativeInstance(
        nativeSampler.toDestination(), samplerJs.toDestination());
  }

  void onLoad(void Function() callback) {
    nativeInstance.on('load', js.allowInterop(callback));
  }
}
