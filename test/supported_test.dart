import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_tone_js/src/export.dart';
import 'package:test/test.dart';

void main() {
  test('supported', () {
    if (kDartIsWeb) {
      expect(isToneJsSupported, isTrue);
    } else {
      expect(isToneJsSupported, isFalse);
    }
  });
}
