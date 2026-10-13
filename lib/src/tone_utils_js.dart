import 'dart:js_interop';

import 'tone_delay.dart';

JSAny durationToJs(Object duration) {
  if (duration is num) {
    return duration.toJS;
  } else if (duration is String) {
    return duration.toJS;
  }
  throw ArgumentError('Invalid duration type: ${duration.runtimeType}');
}

JSAny delayToJs(Object delay) => toneJsDelayExpression(delay).toJS;
