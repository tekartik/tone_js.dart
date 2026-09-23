/// Common tone API with its two implementations: [toneFactoryJs] (Tone.js
/// wrapper) and [toneFactoryWeb] (pure Dart, Web Audio API).
///
/// Safe to import on any platform (the implementations are only supported
/// on the web).
library;

import 'src/tone_js_factory.dart';
import 'src/web/tone_web.dart';

export 'src/api/tone_api.dart'
    show
        ToneContextApi,
        ToneInstrumentApi,
        ToneSynthApi,
        ToneSamplerApi,
        ToneFactory;
export 'src/tone_js_factory.dart' show toneFactoryJs;
export 'src/web/tone_web.dart' show toneFactoryWeb;
