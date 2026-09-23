/// Port of Tone.js 14.7.77 `Sampler` (instrument/Sampler.ts).
library;

import 'package:web/web.dart' as web;

import '../api/tone_api.dart';
import '../common/tone_envelope.dart';
import '../common/tone_sampler_utils.dart';
import '../common/tone_time.dart';
import 'tone_web_context.dart';
import 'tone_web_source.dart';

/// Plays the closest sample, pitch shifted, one source per note played.
class ToneWebSamplerImpl implements ToneSamplerApi {
  /// The context.
  final ToneWebContextImpl context;

  /// Decoded samples by midi note.
  final Map<int, web.AudioBuffer> buffers;

  /// Instrument output.
  final web.GainNode output;

  /// Fade in time of each note.
  double attack = 0;

  /// Fade out time of each note when released.
  double release = 0.1;

  /// Fade curve.
  ToneEnvelopeCurve curve = ToneEnvelopeCurve.exponential;

  final _activeSources = <int, List<ToneWebBufferSource>>{};

  /// Sampler.
  ToneWebSamplerImpl(this.context, this.buffers)
    : output = context.audioContext.createGain();

  @override
  ToneWebSamplerImpl toDestination() {
    output.connect(context.destination);
    return this;
  }

  @override
  void triggerAttack(String note, {Object? delay}) {
    context.ensureRunning();
    attackAt(note, context.delayToTime(delay));
  }

  @override
  void triggerRelease(String note, {Object? delay}) {
    context.ensureRunning();
    releaseAt(note, context.delayToTime(delay));
  }

  @override
  void triggerAttackRelease(String note, Object duration, {Object? delay}) {
    context.ensureRunning();
    var time = context.delayToTime(delay);
    var computedDuration = context.durationToSeconds(duration);
    attackAt(note, time);
    releaseAt(note, time + computedDuration);
  }

  /// Starts playing [note] at [time].
  void attackAt(String note, double time, [double velocity = 1]) {
    var midiFloat = toneFtomf(context.noteToFrequency(note));
    var midi = toneJsRound(midiFloat);
    var remainder = midiFloat - midi;
    // find the closest note pitch
    var difference = toneSamplerFindClosest(midi, buffers.containsKey);
    var closestNote = midi - difference;
    var buffer = buffers[closestNote]!;
    var playbackRate = toneIntervalToFrequencyRatio(difference + remainder);
    var source = ToneWebBufferSource(
      context,
      buffer,
      curve: curve,
      fadeIn: attack,
      fadeOut: release,
      playbackRate: playbackRate,
    )..connect(output);
    source.start(
      time,
      duration: buffer.duration / playbackRate,
      gainValue: velocity,
    );
    var sources = _activeSources[midi] ??= <ToneWebBufferSource>[];
    sources.add(source);
    source.onended = () {
      _activeSources[midi]?.remove(source);
    };
  }

  /// Releases all the sources playing [note] at [time].
  void releaseAt(String note, double time) {
    var midi = context.timeConverter.toMidi(note);
    var sources = _activeSources[midi];
    if (sources != null && sources.isNotEmpty) {
      _activeSources[midi] = <ToneWebBufferSource>[];
      for (var source in sources) {
        source.stop(time);
      }
    }
  }

  /// Releases all the notes being played at [time] (now if null).
  void releaseAll([double? time]) {
    var computedTime = time ?? context.now();
    for (var sources in _activeSources.values) {
      while (sources.isNotEmpty) {
        sources.removeAt(0).stop(computedTime);
      }
    }
  }
}
