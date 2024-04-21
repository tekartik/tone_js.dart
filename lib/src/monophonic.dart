import 'dart:js_interop';
import 'dart:js_util' as js;

import 'instrument.dart';
import 'js_interop.dart' as tonejs;
import 'js_interop_compat.dart' as tone_js;
import 'tone.dart';
import 'tone_utils_js.dart';

extension MonophonicExt on Monophonic {
  void triggerAttack(String note, {Object? delay}) {
    JSAny? timeJs;
    if (delay != null) {
      timeJs = delayToJs(delay);
    }
    if (timeJs == null) {
      //nativeInstance.triggerAttack(note);
      monophonicJs.triggerAttack(note.toJS);
    } else {
      monophonicJs.triggerAttack(note.toJS, timeJs);
      //nativeInstance.triggerAttack(note, time);
    }
  }

  void triggerRelease({Object? delay}) {
    JSAny? timeJs;
    if (delay != null) {
      timeJs = delayToJs(delay);
    }
    if (timeJs == null) {
      //nativeInstance.triggerAttack(note);
      monophonicJs.triggerRelease();
    } else {
      monophonicJs.triggerRelease(timeJs);
      //nativeInstance.triggerAttack(note, time);
    }
  }

  void triggerAttackRelease(String note, Object duration, {Object? delay}) {
    JSAny? timeJs;
    if (delay != null) {
      timeJs = delayToJs(delay);
    }
    if (timeJs == null) {
      //nativeInstance.triggerAttackRelease(note, duration);
      monophonicJs.triggerAttackRelease(note.toJS, durationToJs(duration));
    } else {
      monophonicJs.triggerAttackRelease(
          note.toJS, durationToJs(duration), timeJs);
    }
  }
}

class Monophonic extends Instrument {
  Monophonic.fromNativeInstance(
      tone_js.Synth super.nativeInstance, tonejs.SynthJs super.instrumentJs);

  Monophonic()
      : super(
            js.callConstructor(toneContext.nativeInstance.Synth, [])
                as tone_js.Synth,
            toneContext.toneJs.newSynth());
}

extension MonophonicPrvExt on Monophonic {
  tonejs.MonophonicJs get monophonicJs => instrumentJs as tonejs.SynthJs;
}
