import 'package:tekartik_tone_js/tone_js.dart';
import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

main() async {
  await initTestMenuBrowser();

  menu("main", () {
    item('Hello Tone', () {
      // create one of Tone's built-in synthesizers and connect it to the master output
      var synth = new SimpleSynth().toMaster();

      // play a middle c for the duration of an 8th note
      synth.triggerAttackRelease("C4", "8n");
    });
    item('Oscillator', () {
      var osc =
          new Oscillator(new OscillatorOptions(frequency: 440, volume: -10))
              .toMaster();
      osc.start();
      osc.volume.rampTo(0, 0.05);
      osc.volume.rampTo(double.negativeInfinity, 1.05);
      //}
    });
  });
}
