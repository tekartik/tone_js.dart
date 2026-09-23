import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'tone_web_api.dart';
import 'tone_web_context.dart';

ToneWebContextImpl? _toneWebContext;

/// True if the Web Audio API is available.
bool get isToneWebSupported => globalContext.has('AudioContext');

/// The context created by [initToneWebContext], if any.
ToneWebContext? get toneWebContextOrNull => _toneWebContext;

/// Creates (once) the shared audio context.
///
/// Browsers only start audio after a user gesture: call it (or trigger the
/// first note) from a click/tap handler.
Future<ToneWebContext> initToneWebContext({double? lookAhead}) async {
  var context = _toneWebContext ??= ToneWebContextImpl(
    web.AudioContext(),
    lookAhead: lookAhead,
  );
  if (lookAhead != null) {
    context.lookAhead = lookAhead;
  }
  return context;
}
