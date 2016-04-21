library tekartik.mdl_js.loader;

import 'package:tekartik_utils/js_utils.dart';
import 'dart:async';
import 'dart:js' as js;

Future loadToneJs() async {
  /*
  // already loaded?
  if (js.context['componentHandler'] != null) {
    return null;
  }
  */

  // load mdl js
  await loadJavascriptScript("packages/tone_js/js/Tone.min.js");
  return null;
}
