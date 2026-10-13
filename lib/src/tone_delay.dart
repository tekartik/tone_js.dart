/// Tone.js relative time expression ('+' prefixed) for a delay.
///
/// A leading '+' in a String delay is ignored, as in tone_web, so that '+0.5'
/// is not sent as '++0.5' (which Tone.js reads as now + now + 0.5).
String toneJsDelayExpression(Object delay) {
  if (delay is num) {
    return '+$delay';
  } else if (delay is String) {
    var trimmed = delay.trim();
    if (trimmed.startsWith('+')) {
      trimmed = trimmed.substring(1);
    }
    return '+$trimmed';
  }
  throw ArgumentError('Invalid delay type: ${delay.runtimeType}');
}
