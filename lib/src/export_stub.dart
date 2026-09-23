import 'api/tone_api.dart';

/// Supported on web only
bool get isToneJsSupported => false;

/// Throws [UnsupportedError] outside the web.
Future<ToneContextApi> initToneJsContextApi() async {
  throw UnsupportedError('tone_js is only supported on the web');
}
