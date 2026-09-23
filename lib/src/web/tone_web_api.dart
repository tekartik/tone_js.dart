import '../api/tone_api.dart';

/// tone_web implementation version.
const toneWebVersion = '0.7.0';

/// Pure Dart (Web Audio API) tone context.
abstract interface class ToneWebContext implements ToneContextApi {
  /// Delay in seconds added to [currentTime] to schedule events, 0.1 by
  /// default like Tone.js (0 for an offline context). Lower it for lower
  /// latency.
  abstract double lookAhead;

  /// The audio context time, in seconds.
  double get currentTime;

  /// [currentTime] + [lookAhead], the reference time for delays.
  double now();

  /// Resumes the audio context, call it from a user gesture (click, tap)
  /// if the context was created before any user interaction.
  ///
  /// Triggering a note also tries to resume a suspended context.
  Future<void> resume();
}
