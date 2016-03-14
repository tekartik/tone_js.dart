@JS('Tone')
library tone_js;

import 'package:js/js.dart';

@JS()
class Instrument {
  external triggerAttackRelease(String note, String duration);
}

@JS()
class SimpleSynth {
  external SimpleSynth();
  external Instrument toMaster();
}
