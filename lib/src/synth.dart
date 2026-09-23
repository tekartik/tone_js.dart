import 'api/tone_api.dart';
import 'instrument.dart';
import 'js_interop.dart' as tonejs;
import 'monophonic.dart';
import 'tone.dart';

class Synth extends Monophonic implements ToneSynthApi {
  Synth.fromNativeInstance(super.instrumentJs) : super.fromNativeInstance();

  Synth() : super.fromNativeInstance(toneContext.toneJs.newSynth());

  // @Deprecated('Use toDestination')
  Synth toMaster() {
    return toDestination();
  }

  @override
  Synth toDestination() {
    return Synth.fromNativeInstance(synthJs.toDestination());
  }
}

extension SynthPrvExt on Synth {
  tonejs.SynthJs get synthJs => instrumentJs as tonejs.SynthJs;
}

extension MonophonicPrvExt on Monophonic {
  tonejs.MonophonicJs get monophonicJs => instrumentJs as tonejs.SynthJs;
}
