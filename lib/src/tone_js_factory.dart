import 'api/tone_api.dart';
import 'export.dart';

class _ToneFactoryJs implements ToneFactory {
  const _ToneFactoryJs();

  @override
  String get name => 'tone_js';

  @override
  bool get isSupported => isToneJsSupported;

  @override
  Future<ToneContextApi> initContext() => initToneJsContextApi();

  @override
  String toString() => name;
}

/// Tone.js based implementation (loads the bundled Tone.js if needed).
const ToneFactory toneFactoryJs = _ToneFactoryJs();
