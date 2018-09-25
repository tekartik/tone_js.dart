import 'package:tekartik_tone_js/tone_js.dart';

main() {
  // create one of Tone's built-in synthesizers and connect it to the master output
  var synth = SimpleSynth().toMaster();

  // play a middle c for the duration of an 8th note
  synth.triggerAttackRelease("C4", "8n");
}
