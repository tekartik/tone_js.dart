---
name: tekartik-tone-js-setup
description: >-
  Use when playing notes or samples in a Dart web app through Tone.js with
  tekartik_tone_js: initToneContext, toneContext, ToneContext (version,
  newSynth, createSampler, context), Synth, Monophonic, MonophonicExt,
  Sampler, SampleExt, triggerAttack / triggerRelease / triggerAttackRelease,
  toDestination (toMaster), ToneAudioContext, ToneGainNode, the
  tone_js_loader.dart helpers loadToneJs and toneJsPath, the bundled
  packages/tekartik_tone_js/js/Tone.js asset, and the web-only / user-gesture
  constraints.
---

# Tone.js wrapper (tekartik_tone_js)

`tekartik_tone_js` is a thin Dart wrapper over [Tone.js](https://tonejs.github.io):
it loads the bundled `Tone.js` (14.7.77, in `lib/js/`), exposes a `ToneContext`
and wraps the parts needed to play notes — `Synth` and `Sampler`. Web only.

## Guidelines

* Dependency (git, not published on pub.dev; the package is at the repository
  root, so there is no `path:`):
  ```yaml
  dependencies:
    tekartik_tone_js:
      git:
        url: https://github.com/tekartik/tone_js.dart
      version: '>=0.1.1'
  ```
  A page that manipulates the DOM also needs `web:` in its own dependencies.
* Imports: `package:tekartik_tone_js/tone.dart` is the API
  (`initToneContext`, `toneContext`, `ToneContext`, `Synth`, `Monophonic`,
  `MonophonicExt`, `Sampler`, `SampleExt`, `Tone`, `ToneAudioContext`,
  `ToneGainNode`); `package:tekartik_tone_js/tone_js_loader.dart` adds
  `loadToneJs({path, debug})` and `toneJsPath({path, debug})` when the script
  must be injected without creating the context. `tone_js.dart` is deprecated
  and empty, `tone_available.dart` is empty: do not import them.
* Web only (`dart:js_interop`). Keep the import out of shared/VM libraries;
  use a conditional import or guard with `kDartIsWeb` from
  `package:tekartik_common_utils/env_utils.dart`. (`isToneJsSupported` exists
  but only in `lib/src/export.dart`, an implementation import.)
* Always `await initToneContext()` before creating any instrument, including
  when the page already has a `<script src="packages/tekartik_tone_js/js/Tone.js">`
  tag: `Synth()` and `toneContext` read the context that `initToneContext`
  installs. The call is lock-guarded and idempotent — calling it in every
  handler is fine, it returns the same `ToneContext`.
* `initToneContext({String? path, bool? debug})` reuses a global `Tone`
  object if the page already defines one, then a `require` loader, otherwise
  it injects the script itself. `path` defaults to
  `packages/tekartik_tone_js/js/Tone.js`, which is the url a Dart web build
  (`webdev serve`, `dart test -p chrome`) serves the package asset from. A
  Flutter web app does not serve `packages/...` that way: copy `Tone.js` into
  `web/` and pass `path: 'Tone.js'`. `debug: true` currently resolves to the
  same file.
* `ToneContext`: `version` (`'14.7.77'` for the bundled file), `newSynth()`,
  `createSampler(Map<String, String> samples, {String? baseUrl})` (awaits
  Tone's `onload`, so the returned `Sampler` is ready to play), and
  `context` (a `ToneAudioContext`, with `createGain()` returning a
  `ToneGainNode` that has `connect`/`disconnect`).
* Instruments must be routed to the output: `Synth().toDestination()` /
  `toneContext.newSynth().toDestination()` /
  `(await toneContext.createSampler(...)).toDestination()`. `toMaster()` is
  the old alias of `toDestination()`. Both return a new wrapper, so keep the
  returned object, not the one you created.
* Playing (extension methods, so `tone.dart` must be imported where they are
  used): `triggerAttack(note, {delay})`, `triggerRelease({delay})` (`Synth` /
  `Monophonic` only) and `triggerAttackRelease(note, duration, {delay})`.
  `note` is a note name (`'C4'`, `'Bb3'`, `'C#3'`).
* `duration` and `delay` are `Object`: a `num` (seconds) or a `String` (Tone
  notation, `'8n'`, `'1'`), anything else throws `ArgumentError`. `delay` is
  always relative to now — it is passed to Tone as `'+<delay>'` — so
  `delay: 1.0` means "in one second"; there is no absolute-time API.
* `createSampler` keys are note names and values are file names, optionally
  with Tone's extension-choice syntax (`'C4': 'audio/C4[.mp3|.ogg]'`);
  `baseUrl` is prefixed to each of them.
* Browsers block audio until a user gesture: create the context and trigger
  notes from a click/tap handler (or from a test menu item), never at page
  load. In a test, expect no sound; assert on the objects only.
* Only `Synth`, `Monophonic` and `Sampler` are wrapped (no `Oscillator`,
  `Transport`, effects). Anything else means adding the interop in
  `lib/src/js_interop.dart` — the raw `ToneJs` object is not exported.
* Tests: `@TestOn('browser')` before `library;`, `await initToneContext()` in
  `setUpAll`. `dart_test.yaml` runs `vm` and `chrome`; a file importing
  `tone.dart` only works on `chrome`.

## Examples

### Minimal page: one note on click

```dart
import 'package:tekartik_tone_js/tone.dart';
import 'package:web/web.dart';

void main() {
  var button = document.querySelector('#play')! as HTMLButtonElement;
  button.onClick.listen((_) async {
    // First call loads packages/tekartik_tone_js/js/Tone.js, next ones reuse it.
    await initToneContext();
    var synth = Synth().toDestination();
    // Middle C for the duration of an 8th note.
    synth.triggerAttackRelease('C4', '8n');
  });
}
```

The page needs nothing more than the compiled script:

```html
<!doctype html>
<html>
<head><script defer src="main.dart.js"></script></head>
<body><button id="play">play</button></body>
</html>
```

### Chord and a delayed arpeggio with one synth per note

```dart
import 'package:tekartik_tone_js/tone.dart';

Future<void> playArpeggio() async {
  var context = await initToneContext();
  for (var (index, note) in ['C4', 'E4', 'G4', 'C5'].indexed) {
    var synth = context.newSynth().toDestination();
    // delay is relative to now, in seconds.
    synth.triggerAttackRelease(note, 0.5, delay: index * 0.25);
  }
}

Future<void> holdAndRelease() async {
  await initToneContext();
  var synth = Synth().toDestination();
  synth.triggerAttack('C4');
  await Future<void>.delayed(const Duration(seconds: 1));
  synth.triggerRelease();
}
```

### Sampler loaded from audio files

```dart
import 'package:tekartik_tone_js/tone.dart';

Future<Sampler> loadPiano() async {
  var context = await initToneContext();
  // Resolves to audio/C4.mp3 or audio/C4.ogg, awaits Tone's onload.
  var sampler = (await context.createSampler({
    'C4': 'C4[.mp3|.ogg]',
  }, baseUrl: 'audio/')).toDestination();
  return sampler;
}

Future<void> playSample() async {
  var sampler = await loadPiano();
  sampler.triggerAttack('C4');
  sampler.triggerAttack('Bb3', delay: 1.0);
  sampler.triggerAttackRelease('D3', 0.5, delay: 2.0);
}
```

### Loading Tone.js from a custom location (Flutter web, copied asset)

```dart
import 'package:tekartik_tone_js/tone.dart';
import 'package:tekartik_tone_js/tone_js_loader.dart';

Future<void> setupTone() async {
  // Just inject the script (no context yet).
  await loadToneJs(path: 'Tone.js');
  // Then wrap the now global Tone object; same path, it is not loaded twice.
  var context = await initToneContext(path: 'Tone.js');
  print('Tone.js ${context.version}'); // ignore: avoid_print
}
```

### Browser test

```dart
@TestOn('browser')
library;

import 'package:tekartik_tone_js/tone.dart';
import 'package:test/test.dart';

void main() {
  group('synth', () {
    setUpAll(() async {
      await initToneContext();
    });
    test('version', () {
      expect(toneContext.version, '14.7.77');
    });
    test('create', () {
      var synth = Synth().toDestination();
      expect(synth, isNotNull);
      // No sound in a unit test: playing needs a user gesture.
    });
  });
}
```

### Manual test menu in a browser page

```dart
import 'package:tekartik_test_menu_browser/test_menu_web.dart';
import 'package:tekartik_tone_js/tone.dart';

Future<void> main() async {
  await initTestMenuBrowser();

  menu('tone', () {
    item('init', () async {
      var context = await initToneContext();
      write('version: ${context.version}');
    });
    item('synth C4', () async {
      var context = await initToneContext();
      context.newSynth().toDestination().triggerAttackRelease('C4', '8n');
    });
    item('sampler C4', () async {
      var context = await initToneContext();
      var sampler = (await context.createSampler({
        'C4': 'audio/C4[.mp3|.ogg]',
      })).toDestination();
      sampler.triggerAttack('C4');
    });
  });
}
```
