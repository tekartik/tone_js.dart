---
name: tekartik-tone-js-web
description: >-
  Use when playing notes or samples in Dart without Tone.js through
  tekartik_tone_js tone_web.dart (pure Dart Web Audio port of Tone.js 14.7.77
  Synth and Sampler): initToneWebContext, toneWebContext, ToneWebContext
  (lookAhead, now, currentTime, resume), isToneWebSupported, and when writing
  implementation agnostic code with tone_api.dart: ToneContextApi,
  ToneSynthApi, ToneSamplerApi, ToneInstrumentApi, ToneFactory,
  toneFactoryJs / toneFactoryWeb, safe imports on non web platforms.
---

# Pure Dart tone implementation (tekartik_tone_js tone_web)

`tone_web.dart` is a Dart port of the Tone.js 14.7.77 code behind `Synth` and
`Sampler` on top of the Web Audio API (`package:web`). It needs no JavaScript,
has the same API as the Tone.js wrapper (`tone.dart`) and renders the same
samples (checked by the package tests).

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_tone_js:
      git:
        url: https://github.com/tekartik/tone_js.dart
      version: '>=0.7.0'
  ```
* Imports:
  * `package:tekartik_tone_js/tone_web.dart`: `initToneWebContext`,
    `toneWebContext`, `toneWebContextOrNull`, `ToneWebContext`,
    `isToneWebSupported`, `toneFactoryWeb`, `toneWebVersion` and the common
    API.
  * `package:tekartik_tone_js/tone_api.dart`: the common API
    (`ToneContextApi`, `ToneInstrumentApi`, `ToneSynthApi`, `ToneSamplerApi`,
    `ToneFactory`) and both implementations `toneFactoryJs` (Tone.js) and
    `toneFactoryWeb` (pure Dart).
  * Both are safe to import on any platform (VM, Flutter mobile/desktop, no
    conditional import needed): outside the web `isToneWebSupported` and
    `ToneFactory.isSupported` are false and `initToneWebContext()` /
    `initContext()` throw an `UnsupportedError`. Never import `src/` files.
* `await initToneWebContext({double? lookAhead})` creates (once) the shared
  `AudioContext` and returns the same `ToneWebContext` on every call. There is
  no Tone.js to load, no `path`.
* Browsers keep audio suspended until a user gesture: create the context and
  trigger notes from a click/tap handler. Triggering a note tries to resume a
  suspended context; `await context.resume()` can also be called from the
  gesture handler. In `dart test -p chrome` the context stays suspended: no
  sound, assert on objects only.
* `ToneWebContext`: `version`, `newSynth()`,
  `createSampler(Map<String, String> samples, {String? baseUrl})`,
  `lookAhead` (0.1s like Tone.js, set 0 for lower latency), `currentTime`,
  `now()` (`currentTime + lookAhead`), `resume()`.
* `createSampler` keys are note names (`'C4'`) or midi numbers (`'60'`),
  values are urls fetched relative to the page, with Tone.js extension choice
  (`'C4[.mp3|.ogg]'`) and data urls supported; `baseUrl` is prefixed as is
  (no `/` added). It completes when all samples are decoded and throws a
  `StateError` if a file cannot be loaded.
* `toDestination()` connects the instrument to the output and returns it;
  without it nothing is heard.
* Playing, same as the Tone.js wrapper: `triggerAttack(note, {delay})`,
  `triggerAttackRelease(note, duration, {delay})`, `triggerRelease({delay})`
  on a synth, `triggerRelease(note, {delay})` on a sampler. `note` is a note
  name (`'C4'`, `'Bb3'`, `'C#3'`, `'Cx4'`) or a frequency (`'440'`). `duration`
  and `delay` are seconds (`num`) or Tone.js time (`'8n'`, `'4n.'`, `'8t'`,
  `'1m'`, `'1:2:0'`, 120 bpm), `delay` is relative to `now()`. Invalid values
  throw an `ArgumentError`.
* Sounds: synth is a triangle oscillator with envelope attack 0.005, decay
  0.1, sustain 0.3, release 1 (monophonic, a new note restarts the envelope
  from its current level); sampler plays the closest sample (upper one on a
  tie, within 8 octaves) pitch shifted, with a 0.1s exponential release.
  Not configurable.
* Write implementation agnostic code against `ToneContextApi` and pick the
  implementation with a `ToneFactory` (`toneFactoryJs` or `toneFactoryWeb`);
  the Tone.js `ToneContext`, `Synth` and `Sampler` implement the same
  interfaces.

## Examples

### Play a chord from a click

```dart
import 'package:tekartik_tone_js/tone_web.dart';
import 'package:web/web.dart';

void main() {
  ToneSamplerApi? sampler;
  var button = document.querySelector('#play')! as HTMLButtonElement;
  button.onClick.listen((_) async {
    var context = await initToneWebContext();
    sampler ??= (await context.createSampler({
      'C4': 'C4[.mp3|.ogg]',
      'A4': 'A4[.mp3|.ogg]',
    }, baseUrl: 'audio/')).toDestination();
    var delay = 0.0;
    for (var note in ['E3', 'A3', 'D4', 'G4', 'B4', 'E5']) {
      sampler!.triggerAttackRelease(note, 1.0, delay: delay);
      delay += 0.1;
    }
  });
}
```

### Switch implementation

```dart
import 'package:tekartik_tone_js/tone_api.dart';

/// Tone.js by default, pure Dart with `?impl=web` in the page url.
ToneFactory toneFactoryFromUrl() =>
    Uri.base.queryParameters['impl'] == 'web' ? toneFactoryWeb : toneFactoryJs;

Future<void> playNote(ToneFactory factory) async {
  var context = await factory.initContext();
  var synth = context.newSynth().toDestination();
  synth.triggerAttackRelease('C4', '8n');
  synth.triggerAttackRelease('E4', '8n', delay: '4n');
}
```

### Shared code compiled for mobile and web

```dart
import 'package:tekartik_tone_js/tone_web.dart';

/// Plays notes on the web, does nothing elsewhere.
class NotePlayer {
  ToneSamplerApi? _sampler;

  Future<void> play(List<String> notes, {double interval = 0.1}) async {
    if (!isToneWebSupported) {
      return;
    }
    var sampler = _sampler ??= (await (await initToneWebContext())
            .createSampler({'C4': 'audio/C4.mp3'}))
        .toDestination();
    var delay = 0.0;
    for (var note in notes) {
      sampler.triggerAttackRelease(note, 1.0, delay: delay);
      delay += interval;
    }
  }
}
```

### Lower latency

```dart
import 'package:tekartik_tone_js/tone_web.dart';

Future<void> playNow() async {
  // No look ahead: notes start at the audio context current time.
  var context = await initToneWebContext(lookAhead: 0);
  context.newSynth().toDestination().triggerAttackRelease('A4', 0.2);
}
```

### Browser and VM test

```dart
import 'package:tekartik_tone_js/tone_web.dart';
import 'package:test/test.dart';

void main() {
  test('tone_web', () async {
    if (!isToneWebSupported) {
      await expectLater(initToneWebContext(), throwsUnsupportedError);
      return;
    }
    var context = await initToneWebContext();
    expect(context.version, toneWebVersion);
    // No sound in a test: the audio context stays suspended.
    context.newSynth().toDestination().triggerAttackRelease('C4', '8n');
  });
}
```
