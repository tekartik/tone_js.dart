# Tone.js wrapper and pure Dart implementation

Play notes and samples in a Dart web app, either through [Tone.js](https://tonejs.github.io)
or through a pure Dart port of Tone.js `Synth` and `Sampler` (Web Audio API,
no JavaScript dependency).

## Setup

```yaml
dependencies:
  tekartik_tone_js:
    git:
      url: https://github.com/tekartik/tone_js.dart
    version: '>=0.7.0'
```

## Libraries

| Import | Content | Platforms |
| --- | --- | --- |
| `package:tekartik_tone_js/tone.dart` | Tone.js wrapper (`initToneContext`, `Synth`, `Sampler`) | web only |
| `package:tekartik_tone_js/tone_web.dart` | pure Dart implementation (`initToneWebContext`) | safe to import anywhere, supported on web |
| `package:tekartik_tone_js/tone_api.dart` | common API and both implementations (`toneFactoryJs`, `toneFactoryWeb`) | safe to import anywhere, supported on web |

Both implementations share the same API (`ToneContextApi`, `ToneSynthApi`,
`ToneSamplerApi`):

```dart
import 'package:tekartik_tone_js/tone_web.dart';

Future<void> playChord() async {
  // Pure Dart, no Tone.js needed. Call it from a click/tap handler.
  var context = await initToneWebContext();
  var sampler = (await context.createSampler({
    'C4': 'audio/C4[.mp3|.ogg]',
  })).toDestination();
  var delay = 0.0;
  for (var note in ['E3', 'A3', 'D4', 'G4']) {
    sampler.triggerAttackRelease(note, 1.0, delay: delay);
    delay += 0.1;
  }
}
```

Switching implementation:

```dart
import 'package:tekartik_tone_js/tone_api.dart';

Future<void> play({required bool useToneJs}) async {
  var factory = useToneJs ? toneFactoryJs : toneFactoryWeb;
  var context = await factory.initContext();
  context.newSynth().toDestination().triggerAttackRelease('C4', '8n');
}
```

On non web platforms (VM, Flutter mobile/desktop), `tone_web.dart` and
`tone_api.dart` can be imported: `isToneWebSupported` and
`ToneFactory.isSupported` are false and initializing a context throws an
`UnsupportedError`.

## tone_web

`tone_web` is a port of the Tone.js 14.7.77 code used by `Synth` (triangle
oscillator, amplitude envelope attack 0.005 / decay 0.1 / sustain 0.3 /
release 1) and `Sampler` (closest sample pitch shifting, 0.1s exponential
release), including the Tone.js automation model (`Param`, `Timeline`,
`Envelope`) and the time/note expressions (`'8n'`, `'4n.'`, `'1m'`, `'C#4'`,
`'Bb3'`...).

Like Tone.js, events are scheduled with a 0.1s look ahead; lower it for lower
latency with `initToneWebContext(lookAhead: 0)` or `toneWebContext.lookAhead`.
A suspended audio context is resumed when a note is triggered.

The tests render the same scenarios offline with Tone.js and with tone_web,
the rendered samples are identical.

## Examples

```bash
dart run tool/example_serve.dart
```

- http://localhost:8060/index.html (links to each example with both
  implementations)
- http://localhost:8060/tone_example.html (Tone.js, switch implementation in
  the `implementation` menu)
- http://localhost:8060/tone_example_loader.html?impl=web (tone_web, Tone.js is
  never loaded)
- http://localhost:8060/hello_tone.html?impl=web
