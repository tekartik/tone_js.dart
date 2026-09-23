import 'tone_impl.dart';

/// hello_tone.html uses Tone.js (loaded on demand, preloaded in
/// hello_tone_with_preload.html), hello_tone.html?impl=web the pure Dart
/// implementation.
Future<void> main() async {
  var context = await toneFactoryFromUri().initContext();
  // create a synthesizer and connect it to the output
  var synth = context.newSynth().toDestination();

  // play a middle c for the duration of an 8th note
  synth.triggerAttackRelease('C4', '8n');
}
