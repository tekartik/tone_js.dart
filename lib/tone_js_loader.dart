library;

import 'dart:async';

import 'package:tekartik_browser_utils/js_utils.dart';

// bool get isToneJsLoaded => js.context['Tone'] != null;

/// Tone.js path, the bundled one by default ([debug] is ignored, only the
/// release Tone.js is bundled).
String toneJsPath({String? path, bool? debug}) {
  path ??= 'packages/tekartik_tone_js/js/Tone.js';
  return path;
}

// Perform no check
Future<void> loadToneJs({String? path, bool? debug}) async {
  path = toneJsPath(path: path, debug: debug);
  // load js
  await loadJavascriptScript(path);
}
