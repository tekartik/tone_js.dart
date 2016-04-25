import 'package:tone_js/tone_js.dart';
import 'package:tekartik_test_menu/test_menu_mdl_browser.dart';
import 'package:tekartik_test_menu/test_menu.dart';

main() async {
  await initTestMenuBrowser();

  TestMenu subSubMenu = new TestMenu("sub sub");
  subSubMenu.add("print hi", () => print('hi'));

  TestMenu subMenu = new TestMenu("sub");
  subMenu.add("print hi", () => print('hi'));
  subMenu.addMenu(subSubMenu);

  TestMenu menu = new TestMenu("main");
  menu.add('Hello Tone', () {
    // create one of Tone's built-in synthesizers and connect it to the master output
    var synth = new SimpleSynth().toMaster();

    // play a middle c for the duration of an 8th note
    synth.triggerAttackRelease("C4", "8n");
  });
  menu.add('Oscillator', () {
    var osc = new Oscillator(new OscillatorOptions(frequency: 440, volume: -10))
        .toMaster();
    osc.start();
    osc.volume.rampTo(0, 0.05);
    osc.volume.rampTo(double.NEGATIVE_INFINITY, 1.05);
    //}
  });
  menu.add("print hi", () => print('hi'));
  menu.addMenu(subMenu);
  showTestMenu(menu);
}
