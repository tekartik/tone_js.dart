library tekartik.mdl_js.loader;

import 'dart:async';

import 'package:tekartik_browser_utils/js_utils.dart';

// bool get isToneJsLoaded => js.context['Tone'] != null;

String toneJsPath({String path, bool debug}) {
  path ??=
      'packages/tekartik_tone_js/js/${debug == true ? 'Tone.js' : 'Tone.min.js'}';
  return path;
}

// Perform no check
Future loadToneJs({String path, bool debug}) async {
  path = toneJsPath(path: path, debug: debug);
  // load js
  await loadJavascriptScript(
      "packages/tekartik_tone_js/js/${debug == true ? 'Tone.js' : 'Tone.min.js'}");
}
