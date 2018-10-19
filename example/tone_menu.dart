import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
import 'package:tekartik_tone_js/tone.dart';

mainToneMenu() async {
  menu('tone', () {
    item('initToneContext', () async {
      var toneContext = await initToneContext();
      write(toneContext.version);
    });

    item('Sampler', () async {
      var ctx = await initToneContext(debug: true);
      write('version: ${ctx.version}');
      var sampler =
          (await ctx.createSampler({'C4': 'audio/C4[.mp3|.ogg]'})).toMaster();

      sampler.triggerAttack('C4');
      sampler.triggerAttack('Bb3', delay: 1.0);
      sampler.triggerAttack('C#3', delay: 2.0);
    });
  });
}
