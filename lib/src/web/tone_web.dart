import '../api/tone_api.dart';
import 'tone_web_api.dart';
import 'tone_web_platform.dart';

export 'tone_web_api.dart';
export 'tone_web_platform.dart';

/// The context created by [initToneWebContext].
///
/// Throws a [StateError] if not initialized yet.
ToneWebContext get toneWebContext =>
    toneWebContextOrNull ??
    (throw StateError(
      'toneWebContext not initialized yet, call initToneWebContext first',
    ));

class _ToneFactoryWeb implements ToneFactory {
  const _ToneFactoryWeb();

  @override
  String get name => 'tone_web';

  @override
  bool get isSupported => isToneWebSupported;

  @override
  Future<ToneContextApi> initContext() => initToneWebContext();

  @override
  String toString() => name;
}

/// Pure Dart implementation (Web Audio API), no Tone.js needed.
const ToneFactory toneFactoryWeb = _ToneFactoryWeb();
