import 'package:tekartik_test_menu_browser/test_menu_web.dart';
import 'package:tekartik_tone_js/tone_api.dart';

import 'tone_impl.dart';

/// Implementation used by the menus, `?impl=web` in the url to start with
/// tone_web.
var toneFactory = toneFactoryFromUri();

void mainToneMenu() {
  menu('implementation', () {
    item('show', () {
      write('implementation: $toneFactory');
    });
    item('use tone_js (Tone.js)', () {
      toneFactory = toneFactoryJs;
      write('implementation: $toneFactory');
    });
    item('use tone_web (pure Dart)', () {
      toneFactory = toneFactoryWeb;
      write('implementation: $toneFactory');
    });
  });
  menu('tone', () {
    item('initContext', () async {
      var ctx = await toneFactory.initContext();
      write('$toneFactory version: ${ctx.version}');
    });

    item('Quick sampler', () async {
      var ctx = await toneFactory.initContext();
      write('$toneFactory version: ${ctx.version}');
      var sampler = (await ctx.createSampler({
        'C4': 'audio/C4[.mp3|.ogg]',
      })).toDestination();

      sampler.triggerAttack('C4');
      sampler.triggerAttack('Bb3', delay: 1.0);
      sampler.triggerAttack('C#3', delay: 2.0);
      sampler.triggerAttackRelease('D3', .5, delay: 3.0);
    });

    item('Quick synth', () async {
      var ctx = await toneFactory.initContext();
      var synth = ctx.newSynth().toDestination();
      synth.triggerAttack('C4');
      synth.triggerAttackRelease('D3', .5, delay: .5);
      await sleep(100);
      synth.triggerAttackRelease('E4', .5, delay: .5);
    });

    item('Chord (web player)', () async {
      var ctx = await toneFactory.initContext();
      var sampler = (await ctx.createSampler({
        'C4': 'audio/C4[.mp3|.ogg]',
      })).toDestination();
      var time = 0.0;
      for (var note in ['E3', 'A3', 'D4', 'G4', 'B4', 'E5']) {
        sampler.triggerAttackRelease(note, 1.0, delay: time);
        time += 0.1;
      }
    });
  });
  menu('Initialized', () {
    late ToneContextApi toneContext;
    enter(() async {
      toneContext = await toneFactory.initContext();
      write('implementation: $toneFactory');
    });
    menu('Sampler', () {
      late ToneSamplerApi sampler;

      enter(() async {
        sampler = (await toneContext.createSampler({
          'C4': 'audio/C4[.mp3|.ogg]',
        })).toDestination();
      });
      item('triggerAttack', () async {
        // play a middle c without duration (taken from the sample)
        sampler.triggerAttack('C4');
      });
      item('triggerRelease', () async {
        sampler.triggerRelease('C4');
      });
      item('triggerAttackRelease', () async {
        // play a middle c for the duration of an 8th note
        sampler.triggerAttackRelease('C4', '8n');
      });

      item('triggerAttackRelease delay', () async {
        sampler.triggerAttackRelease('D3', .5, delay: 3.0);
      });
      item('triggerAttack delay', () async {
        sampler.triggerAttack('Bb3', delay: 1.0);
      });
    });
    menu('Synth', () {
      late ToneSynthApi synth;

      enter(() {
        // create a synthesizer and connect it to the output
        synth = toneContext.newSynth().toDestination();
      });
      item('triggerAttackRelease', () async {
        // play a middle c for the duration of an 8th note
        synth.triggerAttackRelease('C4', '8n');
      });

      item('triggerAttackRelease delay', () async {
        synth.triggerAttackRelease('D3', .5, delay: 3.0);
      });
      item('triggerAttack delay', () async {
        synth.triggerAttack('Bb3', delay: 1.0);
      });
      item('triggerAttack', () async {
        // play a middle c
        synth.triggerAttack('C4');
      });
      item('triggerRelease', () async {
        synth.triggerRelease();
      });
    });
  });
}
