@JS('Tone')
library tone_js;

import 'package:js/js.dart';

@JS('GainNode')
class GainNode {
  external connect(p1, [p2, p3]);
  external disconnect([p1]);
}

@JS('AudioContext')
class AudioContext {
  external GainNode createGain();
}

@JS()
@anonymous
class InstrumentOptions {
  external factory InstrumentOptions({int volume});
  external int get volume;
}

@JS('Tone')
class Tone {
  external set(param, [value, rampTime]);
  external get([param]);
  external connect(p1, [p2, p3]);
  external disconnect([p1]);
  external void dispose();
}

@JS()
@anonymous
class VolumeOptions {
  external factory VolumeOptions({int volume});
}

@JS()
class Param {
  external num get value;
}

@JS()
class Volume extends Tone {
  external factory Volume(
      [dynamic /* VolumeOptions or decibel value */ optionsOrValue]);

  external Param get volume;
}

@JS()
class Instrument extends Tone {
  external Instrument([dynamic /*InstrumentOptions */ options]);
  // note is String (C4) or num (440)
  external triggerAttackRelease(var note, String duration);
  external Param get volume;
}

@JS()
class SimpleSynth {
  external SimpleSynth();
  external Instrument toMaster();
}

@JS()
external String get version;

@JS()
external AudioContext get context;
