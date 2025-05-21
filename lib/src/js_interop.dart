import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('Tone')
external ToneJs? get globalToneJsOrNull;

extension type ToneJs._(JSObject _) implements JSObject {
  @JS('Synth')
  external JSFunction newSynthFn;
  @JS('Sampler')
  external JSFunction newSamplerFn;
  @JS('Monophonic')
  external JSFunction newMonophonicFn;
}

extension ToneJsExt on ToneJs {
  external String get version;
  // Audio context
  external AudioContextJs get context;

  SynthJs newSynth() => newSynthFn.callAsConstructor<SynthJs>();
  MonophonicJs newMonophonic() =>
      newMonophonicFn.callAsConstructor<MonophonicJs>();

  SamplerJs newSampler(JSAny samples, [SamplerOptionsJs? options]) =>
      newSamplerFn.callAsConstructor<SamplerJs>(samples, options);
}

extension type InstrumentJs._(JSObject _) implements JSObject {}
extension type SynthJs._(JSObject _) implements MonophonicJs {}
extension type MonophonicJs._(JSObject _) implements InstrumentJs {}
extension type SamplerJs._(JSObject _) implements InstrumentJs {}

extension type SamplerOptionsJs._(JSObject _) implements JSObject {
  external SamplerOptionsJs({required JSFunction onload, String? baseUrl});

  external JSFunction get onload;

  external String? get baseUrl;
}

extension InstrumentJsExt on InstrumentJs {
  external InstrumentJs toDestination();
}

extension MonophonicJsExt on MonophonicJs {
  // https://tonejs.github.io/docs/13.8.25/Synth#triggerattackrelease
  external void triggerAttackRelease(JSAny note, JSAny duration, [JSAny? time]);

  // https://tonejs.github.io/docs/13.8.25/Sampler#triggerattack
  external void triggerAttack(JSAny note, [JSAny? time]);

  external void triggerRelease([JSAny? time]);
  external MonophonicJs toDestination();
}

extension SynthJsExt on SynthJs {
  external SynthJs toDestination();
}

extension SamplerJsExt on SamplerJs {
  external SamplerJs toDestination();

  // https://tonejs.github.io/docs/13.8.25/Synth#triggerattackrelease
  external void triggerAttackRelease(JSAny note, JSAny duration, [JSAny? time]);

  // https://tonejs.github.io/docs/13.8.25/Sampler#triggerattack
  external void triggerAttack(JSAny note, [JSAny? time]);
}

@JS('require')
external JSAny? globalRequireJsOrNull;

@JS('require')
external JSAny requireJs(JSArray<JSString> ids, JSFunction callback);

extension type GainNodeJs._(JSObject _) implements JSObject {}

extension GainNodeJsExt on GainNodeJs {
  external void connect(JSAny p1, [JSNumber? p2, JSNumber? p3]);
  external void disconnect([JSAny? p1]);
}

extension type AudioContextJs._(JSObject _) implements JSObject {}

extension AudioContextJsExt on AudioContextJs {
  external GainNodeJs createGain();
}
