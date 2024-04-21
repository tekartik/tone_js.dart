import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
import 'package:tekartik_tone_js/tone.dart';

void mainToneMenu() {
  menu('tone', () {
    item('initToneContext', () async {
      var toneContext = await initToneContext();
      write(toneContext.version);
    });

    item('Sampler', () async {
      var ctx = await initToneContext(debug: true);
      write('version: ${ctx.version}');
      var sampler = (await ctx.createSampler({'C4': 'audio/C4[.mp3|.ogg]'}))
          .toDestination();

      sampler.triggerAttack('C4');
      sampler.triggerAttack('Bb3', delay: 1.0);
      sampler.triggerAttack('C#3', delay: 2.0);
      sampler.triggerAttackRelease('D3', .5, delay: 3.0);
    });

    item('Synth', () async {
      var ctx = await initToneContext();
      //write('version: ${ctx.version}');
      var synth = ctx.newSynth().toDestination();
      synth.triggerAttack('C4');
      synth.triggerAttackRelease('D3', .5, delay: .5);
      // play a middle c for the duration of an 8th note
      // synth.triggerAttack('C4');
      await sleep(100);
      synth.triggerAttackRelease('E4', .5, delay: .5);
    });
  });
  menu('Initialized', () {
    late ToneContext toneContext;
    enter(() async {
      toneContext = await initToneContext();
    });
    menu('Sampler', () {
      late Sampler sampler;

      enter(() async {
        sampler =
            (await toneContext.createSampler({'C4': 'audio/C4[.mp3|.ogg]'}))
                .toDestination();
      });
      item('triggerAttack', () async {
        // play a middle c without duration (taken from the sample)
        sampler.triggerAttack('C4');
      });
      item('triggerAttackRelease', () async {
        // play a middle c for the duration of an 8th note
        sampler.triggerAttackRelease('C4', '8n');
      });

      item('triggerAttackRelease delay', () async {
        // play a middle c for the duration of an 8th note
        sampler.triggerAttackRelease('D3', .5, delay: 3.0);
      });
      item('triggerAttack delay', () async {
        // play a middle c for the duration of an 8th note
        sampler.triggerAttack('Bb3', delay: 1.0);
      });
    });
    menu('Synth', () {
      late Synth synth;

      enter(() {
        // create one of Tone's built-in synthesizers and connect it to the master output
        synth = Synth().toDestination();
      });
      item('triggerAttackRelease', () async {
        // play a middle c for the duration of an 8th note
        synth.triggerAttackRelease('C4', '8n');
      });

      item('triggerAttackRelease delay', () async {
        // play a middle c for the duration of an 8th note
        synth.triggerAttackRelease('D3', .5, delay: 3.0);
      });
      item('triggerAttack delay', () async {
        // play a middle c for the duration of an 8th note
        synth.triggerAttack('Bb3', delay: 1.0);
      });
      item('triggerAttack', () async {
        // play a middle c
        synth.triggerAttack('C4');
      });
      item('triggerRelease', () async {
        // play a middle c
        synth.triggerRelease();
      });
    });
  });
}
