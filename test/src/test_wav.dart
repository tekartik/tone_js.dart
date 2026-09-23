import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// 16 bits PCM mono wav file.
Uint8List wavEncode(List<double> samples, {int sampleRate = 44100}) {
  var dataLength = samples.length * 2;
  var bytes = ByteData(44 + dataLength);
  void writeString(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      bytes.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  writeString(0, 'RIFF');
  bytes.setUint32(4, 36 + dataLength, Endian.little);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little); // PCM
  bytes.setUint16(22, 1, Endian.little); // mono
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  writeString(36, 'data');
  bytes.setUint32(40, dataLength, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    var value = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    bytes.setInt16(44 + i * 2, value, Endian.little);
  }
  return bytes.buffer.asUint8List();
}

/// A decaying tone with a few harmonics, like a plucked note.
List<double> pluckSamples(
  double frequency, {
  double duration = 1.5,
  int sampleRate = 44100,
}) {
  var length = (duration * sampleRate).round();
  return List<double>.generate(length, (i) {
    var t = i / sampleRate;
    var envelope = min(1.0, t / 0.002) * exp(-3 * t);
    var phase = 2 * pi * frequency * t;
    return 0.5 *
        envelope *
        (sin(phase) + 0.5 * sin(2 * phase) + 0.25 * sin(3 * phase));
  });
}

/// Data url of a pluck wav file.
String pluckWavDataUrl(
  double frequency, {
  double duration = 1.5,
  int sampleRate = 44100,
}) =>
    'data:audio/wav;base64,${base64Encode(wavEncode(
      pluckSamples(frequency, duration: duration, sampleRate: sampleRate),
      sampleRate: sampleRate,
    ))}';
