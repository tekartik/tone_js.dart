import 'api/tone_api.dart';
import 'tone.dart';

/// Supported on web
bool get isToneJsSupported => true;

/// Loads Tone.js if needed (see [initToneContext]).
Future<ToneContextApi> initToneJsContextApi() => initToneContext();
