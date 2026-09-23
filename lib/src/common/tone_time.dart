/// Port of Tone.js 14.7.77 time and frequency expressions
/// (core/type/TimeBase.ts, Time.ts, Frequency.ts, Conversions.ts).
library;

import 'dart:math';

/// Reference frequency of A4.
const toneA4 = 440.0;

/// Midi note to frequency.
double toneMtof(num midi) => toneA4 * pow(2, (midi - 69) / 12);

/// Frequency to (fractional) midi note.
double toneFtomf(num frequency) => 69 + 12 * (log(frequency / toneA4) / ln2);

/// Frequency to midi note.
int toneFtom(num frequency) => toneJsRound(toneFtomf(frequency));

/// Interval in semitones to frequency ratio.
double toneIntervalToFrequencyRatio(num interval) =>
    pow(2.0, interval / 12).toDouble();

/// Javascript `Math.round` (half values are rounded up).
int toneJsRound(num value) => (value + 0.5).floor();

/// Note name to scale index.
const _noteToScaleIndex = <String, int>{
  'cbb': -2, 'cb': -1, 'c': 0, 'c#': 1, 'cx': 2, //
  'dbb': 0, 'db': 1, 'd': 2, 'd#': 3, 'dx': 4, //
  'ebb': 2, 'eb': 3, 'e': 4, 'e#': 5, 'ex': 6, //
  'fbb': 3, 'fb': 4, 'f': 5, 'f#': 6, 'fx': 7, //
  'gbb': 5, 'gb': 6, 'g': 7, 'g#': 8, 'gx': 9, //
  'abb': 7, 'ab': 8, 'a': 9, 'a#': 10, 'ax': 11, //
  'bbb': 9, 'bb': 10, 'b': 11, 'b#': 12, 'bx': 13, //
};

final _noteRegExp = RegExp(
  r'^([a-g]{1}(?:b|#|x|bb)?)(-?[0-9]+)',
  caseSensitive: false,
);
final _hzRegExp = RegExp(r'^(\d+(?:\.\d+)?)hz$', caseSensitive: false);
final _ticksRegExp = RegExp(r'^(\d+)i$', caseSensitive: false);
final _measureRegExp = RegExp(r'^(\d+)m$', caseSensitive: false);
final _notationRegExp = RegExp(r'^(\d+)n(\.?)$', caseSensitive: false);
final _numberRegExp = RegExp(r'^(\d+(?:\.\d+)?)$');
final _secondsRegExp = RegExp(r'^(\d+(?:\.\d+)?)s$');
final _samplesRegExp = RegExp(r'^(\d+)samples$');
final _tripletRegExp = RegExp(r'^(\d+)t$', caseSensitive: false);
final _transportRegExp = RegExp(
  r'^(\d+(?:\.\d+)?):(\d+(?:\.\d+)?):?(\d+(?:\.\d+)?)?$',
);
final _nowRegExp = RegExp(r'^\+(.+)');
final _midiRegExp = RegExp(r'^(\d+(?:\.\d+)?)midi$', caseSensitive: false);
final _parseFloatRegExp = RegExp(
  r'^[+-]?(?:Infinity|(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)',
);

/// Javascript `parseFloat`, NaN if not a number.
double toneJsParseFloat(String text) {
  var match = _parseFloatRegExp.firstMatch(text.trim());
  if (match == null) {
    return double.nan;
  }
  return double.parse(match.group(0)!);
}

/// True if [text] is a note name (`C4`, `Bb3`, `F#-1`...) for Tone.js.
bool toneIsNote(String text) => _noteRegExp.hasMatch(text);

/// Converts Tone.js time and frequency expressions using the Transport
/// defaults (120 bpm, 4/4, 192 ticks per quarter).
class ToneTimeConverter {
  /// Beats per minute.
  final double bpm;

  /// Beats per measure.
  final int timeSignature;

  /// Ticks per quarter note.
  final int ppq;

  /// Sample rate, for `samples` expressions.
  final double sampleRate;

  /// Converter.
  const ToneTimeConverter({
    this.bpm = 120,
    this.timeSignature = 4,
    this.ppq = 192,
    this.sampleRate = 44100,
  });

  double _beatsToSeconds(num beats) => (60 / bpm) * beats;

  double _ticksToSeconds(num ticks) => ticks * _beatsToSeconds(1) / ppq;

  /// Time in seconds from a number (seconds) or a Tone.js time expression
  /// ('4n', '8t', '1m', '1:2:0', '192i', '2hz', '1.5', '+0.5'...).
  ///
  /// Relative expressions ('+0.5') are added to [now].
  double toSeconds(Object time, {double now = 0}) {
    if (time is num) {
      return time.toDouble();
    } else if (time is String) {
      var value = _stringToSeconds(time, now);
      if (value.isNaN) {
        throw ArgumentError.value(time, 'time', 'Invalid time');
      }
      return value;
    }
    throw ArgumentError.value(
      time,
      'time',
      'Invalid time type ${time.runtimeType}',
    );
  }

  double _stringToSeconds(String text, double now) {
    var value = text.trim();
    RegExpMatch? match;
    if ((match = _hzRegExp.firstMatch(value)) != null) {
      return 1 / double.parse(match!.group(1)!);
    } else if ((match = _ticksRegExp.firstMatch(value)) != null) {
      return _ticksToSeconds(int.parse(match!.group(1)!));
    } else if ((match = _measureRegExp.firstMatch(value)) != null) {
      return _beatsToSeconds(int.parse(match!.group(1)!) * timeSignature);
    } else if ((match = _notationRegExp.firstMatch(value)) != null) {
      var numericValue = int.parse(match!.group(1)!);
      var scalar = match.group(2) == '.' ? 1.5 : 1;
      if (numericValue == 1) {
        return _beatsToSeconds(timeSignature) * scalar;
      } else {
        return _beatsToSeconds(4 / numericValue) * scalar;
      }
    } else if ((match = _numberRegExp.firstMatch(value)) != null) {
      return double.parse(match!.group(1)!);
    } else if ((match = _secondsRegExp.firstMatch(value)) != null) {
      return double.parse(match!.group(1)!);
    } else if ((match = _samplesRegExp.firstMatch(value)) != null) {
      return int.parse(match!.group(1)!) / sampleRate;
    } else if ((match = _tripletRegExp.firstMatch(value)) != null) {
      return _beatsToSeconds(8 / (int.parse(match!.group(1)!) * 3));
    } else if ((match = _transportRegExp.firstMatch(value)) != null) {
      var total = 0.0;
      var m = match!.group(1);
      var q = match.group(2);
      var s = match.group(3);
      if (m != null && m != '0') {
        total += _beatsToSeconds(timeSignature * double.parse(m));
      }
      if (q != null && q != '0') {
        total += _beatsToSeconds(double.parse(q));
      }
      if (s != null && s != '0') {
        total += _beatsToSeconds(double.parse(s) / 4);
      }
      return total;
    } else if ((match = _nowRegExp.firstMatch(value)) != null) {
      return now + _stringToSeconds(match!.group(1)!, now);
    }
    return toneJsParseFloat(value);
  }

  /// Frequency in Hz from a number (Hz), a note name ('C4', 'Bb3', 'F#5'),
  /// a frequency ('440hz'), a midi value ('60midi') or a time expression
  /// (inverted, '4n' is 2Hz).
  double toFrequency(Object note) {
    if (note is num) {
      return note.toDouble();
    } else if (note is String) {
      var value = _stringToFrequency(note);
      if (value.isNaN) {
        throw ArgumentError.value(note, 'note', 'Invalid note');
      }
      return value;
    }
    throw ArgumentError.value(
      note,
      'note',
      'Invalid note type ${note.runtimeType}',
    );
  }

  double _stringToFrequency(String text) {
    var value = text.trim();
    RegExpMatch? match;
    if ((match = _hzRegExp.firstMatch(value)) != null) {
      return double.parse(match!.group(1)!);
    } else if ((match = _numberRegExp.firstMatch(value)) != null) {
      return double.parse(match!.group(1)!);
    } else if ((match = _midiRegExp.firstMatch(value)) != null) {
      return toneMtof(double.parse(match!.group(1)!));
    } else if ((match = _noteRegExp.firstMatch(value)) != null) {
      var index = _noteToScaleIndex[match!.group(1)!.toLowerCase()]!;
      var noteNumber = index + (int.parse(match.group(2)!) + 1) * 12;
      return toneMtof(noteNumber);
    } else if (_ticksRegExp.hasMatch(value) ||
        _measureRegExp.hasMatch(value) ||
        _notationRegExp.hasMatch(value) ||
        _secondsRegExp.hasMatch(value) ||
        _tripletRegExp.hasMatch(value)) {
      return 1 / _stringToSeconds(value, 0);
    }
    return toneJsParseFloat(value);
  }

  /// Midi note (rounded) from a note expression.
  int toMidi(Object note) => toneFtom(toFrequency(note));
}

/// Default converter (120 bpm, 4/4).
const toneTimeConverter = ToneTimeConverter();
