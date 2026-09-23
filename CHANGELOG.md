# 0.7.0

* Add `tone_web.dart`, a pure Dart (Web Audio API) implementation ported from
  Tone.js 14.7.77 `Synth` and `Sampler`, no Tone.js needed
* Add `tone_api.dart`, the common API (`ToneContextApi`, `ToneSynthApi`,
  `ToneSamplerApi`) and `toneFactoryJs` / `toneFactoryWeb` to switch
  implementation
* `tone_web.dart` and `tone_api.dart` are safe to import on non web platforms
* The Tone.js wrapper classes implement the common API, trigger methods are
  now class members (the extensions are kept), add `Sampler.triggerRelease`

# 0.3.2

* Simple triggerAttackRelease for playing notes based on a sample