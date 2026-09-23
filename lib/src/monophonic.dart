import 'dart:js_interop';

import 'instrument.dart';
import 'js_interop.dart' as tonejs;
import 'tone.dart';
import 'tone_utils_js.dart';

/// Kept for compatibility, the methods are now [Monophonic] members.
extension MonophonicExt on Monophonic {
  /// See [Monophonic.triggerAttack].
  void triggerAttack(String note, {Object? delay}) =>
      this.triggerAttack(note, delay: delay);

  /// See [Monophonic.triggerRelease].
  void triggerRelease({Object? delay}) => this.triggerRelease(delay: delay);

  /// See [Monophonic.triggerAttackRelease].
  void triggerAttackRelease(String note, Object duration, {Object? delay}) =>
      this.triggerAttackRelease(note, duration, delay: delay);
}

class Monophonic extends Instrument {
  Monophonic.fromNativeInstance(tonejs.SynthJs super.instrumentJs);

  Monophonic() : super(toneContext.toneJs.newSynth());

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
        note.toJS,
        durationToJs(duration),
        timeJs,
      );
    }
  }
}

extension MonophonicPrvExt on Monophonic {
  tonejs.MonophonicJs get monophonicJs => instrumentJs as tonejs.SynthJs;
}
