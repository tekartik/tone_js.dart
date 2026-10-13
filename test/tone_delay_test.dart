import 'package:tekartik_tone_js/src/common/tone_time.dart';
import 'package:tekartik_tone_js/src/tone_delay.dart';
import 'package:test/test.dart';

void main() {
  test('toneJsDelayExpression', () {
    expect(toneJsDelayExpression(0.5), '+0.5');
    expect(toneJsDelayExpression(1), '+1');
    expect(toneJsDelayExpression('0.5'), '+0.5');
    expect(toneJsDelayExpression('4n'), '+4n');
    // A leading '+' is not doubled (Tone.js reads '++0.5' as now + now + 0.5).
    expect(toneJsDelayExpression('+0.5'), '+0.5');
    expect(toneJsDelayExpression(' +4n'), '+4n');
    expect(() => toneJsDelayExpression(true), throwsArgumentError);
  });

  test('delay time as tone_web', () {
    for (var now in [0.0, 60.1]) {
      for (var delay in ['+0.5', '0.5', '+4n', '4n']) {
        // tone_web delayToTime: now + delay without its leading '+'.
        var webDelay = delay.startsWith('+') ? delay.substring(1) : delay;
        expect(
          toneTimeConverter.toSeconds(toneJsDelayExpression(delay), now: now),
          closeTo(now + toneTimeConverter.toSeconds(webDelay, now: now), 1e-9),
          reason: 'now $now delay $delay',
        );
      }
    }
  });
}
