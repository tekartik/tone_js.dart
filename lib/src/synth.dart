import 'dart:js_util' as js;

import 'instrument.dart';
import 'js_interop.dart' as tonejs;
import 'js_interop_compat.dart' as tone_js;
import 'monophonic.dart';
import 'tone.dart';

class Synth extends Monophonic {
  Synth.fromNativeInstance(super.nativeInstance, super.instrumentJs)
      : super.fromNativeInstance();

  Synth()
      : super.fromNativeInstance(
            js.callConstructor(toneContext.nativeInstance.Synth, [])
                as tone_js.Synth,
            toneContext.toneJs.newSynth());

  @Deprecated('Use toDestination')
  Synth toMaster() {
    return toDestination();
  }

  Synth toDestination() {
    return Synth.fromNativeInstance(
        nativeSynth.toDestination(), synthJs.toDestination());
  }
}

extension SynthPrvExt on Synth {
  tonejs.SynthJs get synthJs => instrumentJs as tonejs.SynthJs;
  tone_js.Synth get nativeSynth => nativeInstance as tone_js.Synth;
}

extension MonophonicPrvExt on Monophonic {
  tonejs.MonophonicJs get monophonicJs => instrumentJs as tonejs.SynthJs;
}
