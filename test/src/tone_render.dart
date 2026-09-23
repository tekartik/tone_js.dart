import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';
import 'dart:typed_data';

import 'package:tekartik_tone_js/src/web/tone_web_context.dart';
import 'package:tekartik_tone_js/tone.dart';
import 'package:web/web.dart' as web;

/// Tone.js `ToneAudioBuffer`.
extension type ToneAudioBufferJs._(JSObject _) implements JSObject {
  /// The native buffer.
  external web.AudioBuffer get();
}

@JS('Tone.Offline')
external JSPromise<ToneAudioBufferJs> _toneOffline(
  JSFunction callback,
  num duration,
  int channels,
  num sampleRate,
);

/// Tone.js global object.
@JS('Tone')
external JSObject get toneJsGlobal;

/// Sample rate of the Tone.js (realtime) context.
double get toneJsSampleRate =>
    ((toneJsGlobal['context'] as JSObject)['sampleRate'] as JSNumber)
        .toDartDouble;

/// Default sample rate used for rendering.
const renderSampleRate = 44100;

/// Renders [callback] with Tone.js in an offline context, mono.
///
/// The tone_js wrapper objects created in [callback] (through the global
/// [toneContext]) use the offline context.
Future<Float32List> renderToneJs(
  FutureOr<void> Function(ToneContextApi context) callback, {
  required double duration,
  int sampleRate = renderSampleRate,
}) async {
  var context = await initToneContext();
  var buffer = await _toneOffline(
    ((JSAny? _) => Future<void>.sync(() => callback(context)).toJS).toJS,
    duration,
    1,
    sampleRate,
  ).toDart;
  return buffer.get().getChannelData(0).toDart;
}

/// Renders [callback] with tone_web in an offline context, mono.
Future<Float32List> renderToneWeb(
  FutureOr<void> Function(ToneContextApi context) callback, {
  required double duration,
  int sampleRate = renderSampleRate,
}) async {
  var offline = web.OfflineAudioContext(
    1.toJS,
    (duration * sampleRate).floor(),
    sampleRate,
  );
  var context = ToneWebContextImpl(offline);
  await callback(context);
  var buffer = await offline.startRendering().toDart;
  return buffer.getChannelData(0).toDart;
}

/// Comparison of 2 renders.
class RenderDiff {
  /// Reference render.
  final Float32List expected;

  /// Render to check.
  final Float32List actual;

  /// Max absolute difference.
  late final double maxDiff;

  /// Index of [maxDiff].
  late final int maxDiffIndex;

  /// Root mean square of the difference.
  late final double rmsDiff;

  /// Peak of [expected].
  late final double expectedPeak;

  /// Root mean square of [expected].
  late final double expectedRms;

  /// Compares [actual] to [expected].
  RenderDiff(this.expected, this.actual) {
    var maxDiff = 0.0;
    var maxDiffIndex = -1;
    var sumDiff = 0.0;
    var peak = 0.0;
    var sum = 0.0;
    var length = min(expected.length, actual.length);
    for (var i = 0; i < length; i++) {
      var diff = (expected[i] - actual[i]).abs();
      if (diff > maxDiff) {
        maxDiff = diff;
        maxDiffIndex = i;
      }
      sumDiff += diff * diff;
      peak = max(peak, expected[i].abs());
      sum += expected[i] * expected[i];
    }
    this.maxDiff = maxDiff;
    this.maxDiffIndex = maxDiffIndex;
    rmsDiff = sqrt(sumDiff / length);
    expectedPeak = peak;
    expectedRms = sqrt(sum / length);
  }

  /// Index of the first sample above [threshold] in [samples].
  static int firstSoundIndex(Float32List samples, {double threshold = 1e-4}) {
    for (var i = 0; i < samples.length; i++) {
      if (samples[i].abs() > threshold) {
        return i;
      }
    }
    return -1;
  }

  @override
  String toString() =>
      'maxDiff: $maxDiff at $maxDiffIndex '
      '(${(maxDiffIndex / renderSampleRate).toStringAsFixed(4)}s), '
      'rmsDiff: $rmsDiff, expected peak: $expectedPeak, rms: $expectedRms, '
      'first sound: ${firstSoundIndex(expected)} / ${firstSoundIndex(actual)}';
}

/// Calls a Tone.js object method.
T toneJsCall<T extends JSAny?>(
  JSObject object,
  String method, [
  JSAny? arg1,
  JSAny? arg2,
  JSAny? arg3,
]) => object.callMethod<T>(method.toJS, arg1, arg2, arg3);

/// Creates a Tone.js object (`new Tone.<name>(options)`).
JSObject toneJsNew(String name, [JSAny? options]) =>
    (toneJsGlobal[name] as JSFunction).callAsConstructor<JSObject>(options);
