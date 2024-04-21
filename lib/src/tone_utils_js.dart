import 'dart:js_interop';

JSAny durationToJs(Object duration) {
  if (duration is num) {
    return duration.toJS;
  } else if (duration is String) {
    return duration.toJS;
  }
  throw ArgumentError('Invalid duration type: ${duration.runtimeType}');
}

JSAny delayToJs(Object delay) {
  if (delay is num) {
    return '+$delay'.toJS;
  } else if (delay is String) {
    return '+$delay'.toJS;
  }
  throw ArgumentError('Invalid delay type: ${delay.runtimeType}');
}
