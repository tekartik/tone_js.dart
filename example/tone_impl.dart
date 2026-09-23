import 'package:tekartik_tone_js/tone_api.dart';

/// Implementation selected by the `impl` url parameter: `?impl=web` for
/// tone_web (pure Dart), tone_js (Tone.js) otherwise.
ToneFactory toneFactoryFromUri([Uri? uri]) {
  var impl = (uri ?? Uri.base).queryParameters['impl'];
  return switch (impl) {
    'web' || 'tone_web' => toneFactoryWeb,
    _ => toneFactoryJs,
  };
}
