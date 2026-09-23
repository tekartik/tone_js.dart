/// Common API implemented by the Tone.js wrapper (`tone.dart`) and by the
/// pure Dart Web Audio implementation (`tone_web.dart`).
///
/// Pure Dart, safe to import on any platform.
library;

/// An instrument playing notes.
///
/// `note` is a note name ('C4', 'Bb3', 'C#5') or a frequency in Hz ('440').
/// `duration` and `delay` are a number of seconds or a Tone.js time
/// expression ('8n', '4n.', '1m'). `delay` is always relative to now.
abstract interface class ToneInstrumentApi {
  /// Connects the instrument to the audio output, returns the instrument to
  /// use.
  ToneInstrumentApi toDestination();

  /// Starts playing [note], after [delay] if specified.
  void triggerAttack(String note, {Object? delay});

  /// Plays [note] for [duration], after [delay] if specified.
  void triggerAttackRelease(String note, Object duration, {Object? delay});
}

/// A monophonic synthesizer (one note at a time).
abstract interface class ToneSynthApi implements ToneInstrumentApi {
  @override
  ToneSynthApi toDestination();

  /// Releases the note being played, after [delay] if specified.
  void triggerRelease({Object? delay});
}

/// A polyphonic sampler, playing (pitch shifted) audio samples.
abstract interface class ToneSamplerApi implements ToneInstrumentApi {
  @override
  ToneSamplerApi toDestination();

  /// Releases [note], after [delay] if specified.
  void triggerRelease(String note, {Object? delay});
}

/// The tone context, entry point to create instruments.
abstract interface class ToneContextApi {
  /// Implementation version.
  String get version;

  /// Creates a synthesizer (triangle wave, Tone.js `Synth` defaults).
  ToneSynthApi newSynth();

  /// Creates a sampler from [samples], a map of note ('C4') or midi number
  /// ('60') to url ('audio/C4.mp3'), optionally with Tone.js extension choice
  /// syntax ('audio/C4[.mp3|.ogg]'). [baseUrl] is prefixed to each url.
  ///
  /// Completes when all the samples are loaded.
  Future<ToneSamplerApi> createSampler(
    Map<String, String> samples, {
    String? baseUrl,
  });
}

/// A tone implementation.
abstract interface class ToneFactory {
  /// Implementation name, `tone_js` or `tone_web`.
  String get name;

  /// True if the implementation is supported on the current platform.
  bool get isSupported;

  /// Initializes (once) and returns the shared context.
  ///
  /// Throws [UnsupportedError] if not supported.
  Future<ToneContextApi> initContext();
}
