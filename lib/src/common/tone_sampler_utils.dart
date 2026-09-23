/// Sampler helpers ported from Tone.js 14.7.77 (instrument/Sampler.ts,
/// core/context/ToneAudioBuffer.ts).
library;

import 'tone_time.dart';

/// Midi note of a sampler key, a note name ('C4') or a midi number ('60').
int toneSamplerKeyToMidi(
  String key, {
  ToneTimeConverter converter = toneTimeConverter,
}) {
  if (toneIsNote(key)) {
    return converter.toMidi(key);
  }
  var match = RegExp(r'^\s*([+-]?\d+)').firstMatch(key);
  if (match != null) {
    return int.parse(match.group(1)!);
  }
  throw ArgumentError.value(
    key,
    'key',
    'url key is neither a note or midi pitch',
  );
}

/// Interval between [midi] and the closest available sample, searching
/// within 8 octaves, the upper sample first.
///
/// The sample to use is `midi - interval`.
int toneSamplerFindClosest(int midi, bool Function(int midi) has) {
  const maxInterval = 96;
  var interval = 0;
  while (interval < maxInterval) {
    // check above and below
    if (has(midi + interval)) {
      return -interval;
    } else if (has(midi - interval)) {
      return interval;
    }
    interval++;
  }
  throw StateError('No available buffers for note: $midi');
}

final _extensionChoiceRegExp = RegExp(r'\[([^\]\[]+\|.+)\]$');

/// Resolves Tone.js extension choice syntax: `'C4[.mp3|.ogg]'` becomes
/// `'C4.mp3'` if [supportsType] returns true for 'mp3' (else the first
/// supported one, or the first one).
String toneResolveSampleUrl(
  String url, {
  required bool Function(String extension) supportsType,
}) {
  var match = _extensionChoiceRegExp.firstMatch(url);
  if (match != null) {
    var extensions = match.group(1)!.split('|');
    var extension = extensions.first;
    for (var ext in extensions) {
      if (supportsType(ext.split('.').last)) {
        extension = ext;
        break;
      }
    }
    return url.replaceFirst(match.group(0)!, extension);
  }
  return url;
}
