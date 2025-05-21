@JS()
library;

// ignore_for_file: non_constant_identifier_names

// ignore: deprecated_member_use
import 'package:js/js.dart';

@JS()
@anonymous
class GainNode {
  external dynamic connect(Object? p1, [Object? p2, Object? p3]);
  external dynamic disconnect([Object? p1]);
}

@JS()
@anonymous
class AudioContext {
  external GainNode createGain();
}

@JS()
@anonymous
class InstrumentOptions {
  external factory InstrumentOptions({int? volume});
  external int get volume;
}

@JS()
@anonymous
class Tone {
  external AudioContext get context;
  external String get version;
  // Sampler ctor
  external Function get Sampler;
  // SimpleSynth ctor
  external Function get Synth;
  external dynamic set(Object? param, [Object? value, Object? rampTime]);
  external dynamic get([Object? param]);
  external dynamic connect(Object? p1, [Object? p2, Object? p3]);
  external dynamic disconnect([Object? p1]);
  external dynamic dispose();
  external dynamic toMaster();
  external dynamic toDestination();
}

@JS()
@anonymous
class VolumeOptions {
  external factory VolumeOptions({int? volume});
}

@JS()
@anonymous
class Param {
  external num get value;
}

@JS()
@anonymous
class Volume extends Tone {
  external Param get volume;
  external dynamic rampTo(num value, num delay);
}

/*
  external factory Volume(
      [dynamic /* VolumeOptions or decibel value */ optionsOrValue]);
      */

@JS()
@anonymous
class OscillatorOptions {
  external factory OscillatorOptions({
    int? volume,
    num? frequency,
    num? detune,
    String? type,
  });
  external Param get volume;
  external Param get frequency;
  external Param get detune;
  external String get type;
}

@JS()
@anonymous
class Oscillator extends Tone {
  external dynamic start();
  // OscillatorOptions
  external Param get volume;
  external Param get frequency;
  external Param get detune;
  external String get type;
}

/*
  external Oscillator(
      [dynamic /*OscillatorOptions | num(frequency)*/ options,
      dynamic /* type */ param2]);
 */

@JS()
@anonymous
class SamplerOptions {
  external factory SamplerOptions({Function? onload, String? baseUrl});
  external Function get onload;
  external String get baseUrl;
}

@JS()
@anonymous
class Sampler extends Instrument {
  // external Sampler(dynamic samples, SamplerOptions options);
  @override
  external Sampler toMaster();

  // New name for to Master
  @override
  external Sampler toDestination();
  external void on(String event, Function callback);
}

@JS()
@anonymous
class Master extends Tone {
  external static Volume get volume;
}

@JS()
@anonymous
class Instrument extends Tone {
  // external Instrument([dynamic /*InstrumentOptions */ options]);
  // note is String (C4) or num (440)
  external void triggerAttack(String note, [dynamic time]);
  external void triggerAttackRelease(
    String note,
    dynamic duration, [
    dynamic time,
  ]);
  external Param get volume;
}

@JS()
@anonymous
class Synth extends Instrument {
  // @Deprecated('Use toDestination')
  @override
  external Synth toMaster();

  @override
  external Synth toDestination();
}

// To check if available globally
@JS('Tone')
external Tone get GlobalTone;

external dynamic require(List<String?> id, Function callback);
@JS('require')
external dynamic requireCheck(Object? id);
