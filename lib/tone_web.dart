/// Pure Dart implementation of the tone API using the Web Audio API
/// (no Tone.js needed), ported from Tone.js 14.7.77 `Synth` and `Sampler`.
///
/// Safe to import on any platform: outside the web [isToneWebSupported] is
/// false and [initToneWebContext] throws an [UnsupportedError].
library;

import 'src/web/tone_web.dart';

export 'src/api/tone_api.dart'
    show
        ToneContextApi,
        ToneInstrumentApi,
        ToneSynthApi,
        ToneSamplerApi,
        ToneFactory;
export 'src/web/tone_web.dart'
    show
        ToneWebContext,
        initToneWebContext,
        toneWebContext,
        toneWebContextOrNull,
        isToneWebSupported,
        toneFactoryWeb,
        toneWebVersion;
