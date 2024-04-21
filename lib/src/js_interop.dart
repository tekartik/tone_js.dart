import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('Tone')
external ToneJs? get globalToneJsOrNull;

extension type ToneJs._(JSObject _) implements JSObject {
  @JS('Synth')
  external JSFunction newSynthFn;
  @JS('Sampler')
  external JSFunction newSamplerFn;
}

extension ToneJsExt on ToneJs {
  SynthJs newSynth() => newSynthFn.callAsConstructor<SynthJs>();

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
external JSAny? globalRequireOrNull;
