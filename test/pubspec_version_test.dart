@TestOn('vm')
library;

import 'dart:io';

import 'package:tekartik_tone_js/tone_web.dart';
import 'package:test/test.dart';

void main() {
  test('toneWebVersion matches the pubspec version', () {
    var pubspec = File('pubspec.yaml').readAsStringSync();
    var version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(toneWebVersion, version);
  });
}
