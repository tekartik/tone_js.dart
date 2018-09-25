import 'dart:async';
import 'package:js/js.dart';
import 'package:tekartik_browser_utils/browser_utils_import.dart';
import 'package:tekartik_tone_js/tone_js_loader.dart' as tone_js;
import 'package:tekartik_tone_js/tone_js.dart' as tone_js;
import 'package:synchronized/synchronized.dart';
import 'package:js/js_util.dart' as js;

class ToneContext {
  ToneContext._();

  Future<Sampler> initSampler(Map<String, String> samples) async {
    var completer = Completer();
    Object mapToJSObj(Map<String, String> a) {
      var object = js.newObject();
      a.forEach((k, v) {
        var key = k;
        var value = v;
        js.setProperty(object, key, value);
      });
      return object;
    }

    var sampler = tone_js.Sampler(mapToJSObj(samples),
        tone_js.SamplerOptions(onload: allowInterop(() {
      completer.complete();
    })));
    await completer.future;
    return Sampler(sampler);
  }
}

class Sampler {
  final tone_js.Sampler jsObject;

  Sampler(this.jsObject);

  Sampler toMaster() {
    return Sampler(jsObject.toMaster() as tone_js.Sampler);
  }

  void triggerAttack(String note, {double delay}) {
    dynamic time;
    if (delay != null) {
      time = '+${delay}';
    }
    if (time == null) {
      jsObject.triggerAttack(note);
    } else {
      jsObject.triggerAttack(note, time);
    }
  }
}

ToneContext _toneContext;
final _initLock = Lock();

Future<ToneContext> initToneContext() async {
  if (_toneContext == null) {
    await _initLock.synchronized(() async {
      if (_toneContext == null) {
        await tone_js.loadToneJs();
        _toneContext = ToneContext._();
      }
    });
  }
  return _toneContext;
}
