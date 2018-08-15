library tekartik.mdl_js.loader;

import 'package:tekartik_browser_utils/js_utils.dart';
import 'dart:async';
import 'dart:js' as js;

bool get isToneJsLoaded => js.context['Tone'] != null;
Future loadToneJs() async {
  // already loaded?
  if (isToneJsLoaded) {
    return null;
  }

  // load mdl js
  await loadJavascriptScript("packages/tekartik_tone_js/js/Tone.min.js");
  return null;
}
