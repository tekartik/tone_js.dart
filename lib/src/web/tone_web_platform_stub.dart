import 'tone_web_api.dart';

/// Not supported outside the web.
bool get isToneWebSupported => false;

/// Always null outside the web.
ToneWebContext? get toneWebContextOrNull => null;

/// Throws [UnsupportedError] outside the web.
Future<ToneWebContext> initToneWebContext({double? lookAhead}) async {
  throw UnsupportedError('tone_web is only supported on the web');
}
