@JS('Tone')
library tone_js;

import 'package:js/js.dart';

@JS()
class Instrument {
  // note is String (C4) or num (440)
  external triggerAttackRelease(var note, String duration);
}

@JS()
class SimpleSynth {
  external SimpleSynth();
  external Instrument toMaster();
}
