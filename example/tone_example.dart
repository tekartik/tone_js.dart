import 'package:tekartik_tone_js/tone.dart';

import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
import 'package:tekartik_tone_js/tone_js_loader.dart';

import 'tone_menu.dart';

main() async {
  await initTestMenuBrowser();

  mainToneMenu();

  menu("main", () {
    item('load', () async {
      await loadToneJs();
    });
    item('load debug', () async {
      await loadToneJs(debug: true);
    });
    item('initToneContext', () async {
      await initToneContext();
    });
    item('initToneContext debug', () async {
      await initToneContext(debug: true);
    });
    item('SimpleSynth', () async {
      await initToneContext();
      // create one of Tone's built-in synthesizers and connect it to the master output
      var synth = Synth().toMaster();

      // play a middle c for the duration of an 8th note
      synth.triggerAttackRelease("C4", "8n");
    });
    /*
    item('Oscillator', () {
      var osc =
          Oscillator(OscillatorOptions(frequency: 440, volume: -10)).toMaster();
      osc.start();
      osc.volume.rampTo(0, 0.05);
      osc.volume.rampTo(double.negativeInfinity, 1.05);
      //}
    });
    */
    /*
    item('Sampler', () async {
      var completer = Completer();
      Object mapToJSObj(Map<dynamic, dynamic> a) {
        var object = js.newObject();
        a.forEach((k, v) {
          var key = k;
          var value = v;
          js.setProperty(object, key, value);
        });
        return object;
      }

      write('loading...');
      var sampler = Sampler(mapToJSObj({'C4': 'audio/C4.mp3'}),
          SamplerOptions(onload: allowInterop(() {
        completer.complete();
      }))).toMaster();
      write('waiting...');
      await completer.future;
      write('loaded');
      sampler.triggerAttack('C4');
      sampler.triggerAttack('C3', "+1.0");
      sampler.triggerAttack('C5', "+2.0");
    });
    */
  });
}
