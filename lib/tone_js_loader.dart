library tekartik.mdl_js.loader;

import 'package:tekartik_browser_utils/js_utils.dart';
import 'dart:async';
import 'dart:js' as js;

bool get isToneJsLoaded => js.context['Tone'] != null;

String toneJsPath({String path, bool debug}) {
  path ??= 'packages/tekartik_tone_js/js/${debug == true ? 'Tone.js' :'Tone.min.js'}';
  return path;
}
Future loadToneJs({String path, bool debug}) async {
  path = toneJsPath(path: path, debug: debug);
  // already loaded?
  if (isToneJsLoaded) {
    return null;
  }
  // load mdl js
  await loadJavascriptScript("packages/tekartik_tone_js/js/${debug == true ? 'Tone.js' :'Tone.min.js'}");
  return null;
}
