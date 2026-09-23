import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../common/tone_param.dart';
import '../common/tone_sampler_utils.dart';
import '../common/tone_time.dart';
import 'tone_web_api.dart';
import 'tone_web_param.dart';
import 'tone_web_sampler.dart';
import 'tone_web_synth.dart';

/// Web Audio based context, on a realtime or offline audio context.
class ToneWebContextImpl implements ToneWebContext {
  /// The native audio context.
  final web.BaseAudioContext audioContext;

  /// True for an [web.OfflineAudioContext] (no timers are used).
  final bool isOffline;

  /// Time and note expressions converter.
  final ToneTimeConverter timeConverter;

  @override
  double lookAhead;

  Future<void>? _resumeFuture;

  /// [lookAhead] defaults to 0.1 (0 for an offline context) like Tone.js.
  ToneWebContextImpl(this.audioContext, {double? lookAhead})
    : isOffline = audioContext.isA<web.OfflineAudioContext>(),
      timeConverter = ToneTimeConverter(sampleRate: audioContext.sampleRate),
      lookAhead =
          lookAhead ?? (audioContext.isA<web.OfflineAudioContext>() ? 0 : 0.1);

  @override
  String get version => toneWebVersion;

  /// Sample rate.
  double get sampleRate => audioContext.sampleRate;

  /// Duration of one sample.
  double get sampleTime => 1 / sampleRate;

  /// Audio output.
  web.AudioNode get destination => audioContext.destination;

  @override
  double get currentTime => audioContext.currentTime;

  @override
  double now() => currentTime + lookAhead;

  /// Absolute time of a delay relative to [now] (a leading '+' is ignored).
  double delayToTime(Object? delay) {
    var now = this.now();
    if (delay == null) {
      return now;
    }
    if (delay is String) {
      var trimmed = delay.trim();
      if (trimmed.startsWith('+')) {
        delay = trimmed.substring(1);
      }
    }
    return now + timeConverter.toSeconds(delay, now: now);
  }

  /// Duration in seconds.
  double durationToSeconds(Object duration) =>
      timeConverter.toSeconds(duration, now: now());

  /// Frequency of a note.
  double noteToFrequency(String note) => timeConverter.toFrequency(note);

  /// Automated param on a native param.
  ToneParam newParam(web.AudioParam param, {double? value}) => ToneParam(
    ToneWebAudioParamSink(param),
    initialValue: param.defaultValue,
    sampleTime: sampleTime,
    value: value,
  );

  /// Timer firing when [time] (context time) is reached, null for an offline
  /// context.
  Timer? newTimer(double time, void Function() callback) {
    if (isOffline) {
      return null;
    }
    var delay = time - currentTime;
    return Timer(
      Duration(microseconds: delay > 0 ? (delay * 1000000).round() : 0),
      callback,
    );
  }

  /// Resumes a suspended realtime context (no-op if running).
  void ensureRunning() {
    if (!isOffline && audioContext.state == 'suspended') {
      _resumeFuture ??= resume()
          .catchError((Object _) {})
          .whenComplete(() => _resumeFuture = null);
    }
  }

  @override
  Future<void> resume() async {
    if (audioContext.isA<web.AudioContext>()) {
      await (audioContext as web.AudioContext).resume().toDart;
    }
  }

  @override
  ToneWebSynthImpl newSynth() => ToneWebSynthImpl(this);

  @override
  Future<ToneWebSamplerImpl> createSampler(
    Map<String, String> samples, {
    String? baseUrl,
  }) async {
    var urls = <int, String>{};
    samples.forEach((key, url) {
      urls[toneSamplerKeyToMidi(key, converter: timeConverter)] =
          '${baseUrl ?? ''}$url';
    });
    var buffers = <int, web.AudioBuffer>{};
    await Future.wait(
      urls.entries.map((entry) async {
        buffers[entry.key] = await loadAudioBuffer(entry.value);
      }),
    );
    return ToneWebSamplerImpl(this, buffers);
  }

  /// Loads and decodes an audio file ('[.mp3|.ogg]' extension choice
  /// supported).
  Future<web.AudioBuffer> loadAudioBuffer(String url) async {
    var resolvedUrl = toneResolveSampleUrl(
      url,
      supportsType: _supportsAudioType,
    );
    var response = await web.window.fetch(resolvedUrl.toJS).toDart;
    if (!response.ok) {
      throw StateError(
        'could not load url: $resolvedUrl (status ${response.status})',
      );
    }
    var arrayBuffer = await response.arrayBuffer().toDart;
    return await audioContext.decodeAudioData(arrayBuffer).toDart;
  }

  @override
  String toString() =>
      'ToneWebContext(${isOffline ? 'offline' : 'realtime'}, lookAhead: $lookAhead)';
}

bool _supportsAudioType(String extension) =>
    web.HTMLAudioElement().canPlayType('audio/$extension').isNotEmpty;
