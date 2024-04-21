library tekartik_tone;

import 'dart:js' as js;

import 'package:js/js_util.dart' as js;
import 'package:tekartik_browser_utils/browser_utils_import.dart';
import 'package:tekartik_tone_js/tone_js.dart' as tone_js;
import 'package:tekartik_tone_js/tone_js_loader.dart' as tone_js;
import 'dart:html';

class ToneContext {
  final tone_js.Tone nativeInstance;

  ToneContext._(this.nativeInstance);

  String get version => nativeInstance.version;

  tone_js.AudioContext get context => nativeInstance.context;

  Future<Sampler> createSampler(Map<String, String> samples) async {
    var completer = Completer();
    Object? mapToJSObj(Map<String, String> a) {
      var object = js.newObject();
      a.forEach((k, v) {
        var key = k;
        var value = v;
        js.setProperty(object, key, value);
      });
      return object;
    }

    // devPrint('constructing Sample');
    var nativeSampler = js.callConstructor(nativeInstance.Sampler, [
      mapToJSObj(samples),

      /*
        // 2n argument is onload
        allowInterop(([_]) {
      devPrint('Sampler loaded $_');
      completer.complete();
    })

*/

      tone_js.SamplerOptions(onload: allowInterop(([buffers]) {
        // devPrint('Sampler loaded $_buffers');
        completer.complete();
      }))
    ]) as tone_js.Sampler?;
    // devPrint('nativeSampler $nativeSampler');
    /*
    var sampler = tone_js.Sampler(mapToJSObj(samples),
        tone_js.SamplerOptions(onload: allowInterop(() {
      completer.complete();
    })));
    */
    // await completer.future;
    await completer.future;
    var sampler = Sampler(nativeSampler);
    /*
    sampler.onLoad(() {
      devPrint('loaded');
      completer.complete();
    });
    */
    return sampler;
  }
}

class Tone {}

class Sampler extends Tone {
  final tone_js.Sampler? nativeInstance;

  Sampler(this.nativeInstance) {
    // devPrint('Sample $nativeInstance');
  }

  Sampler toMaster() {
    return Sampler(nativeInstance!.toMaster());
  }

  void triggerAttack(String note, {dynamic delay}) {
    dynamic time;
    if (delay != null) {
      time = '+$delay';
    }
    if (time == null) {
      nativeInstance!.triggerAttack(note);
    } else {
      nativeInstance!.triggerAttack(note, time);
    }
  }

  void triggerAttackRelease(String note, dynamic duration, {dynamic delay}) {
    String? time;
    if (delay != null) {
      time = '+$delay';
    }
    if (time == null) {
      nativeInstance!.triggerAttackRelease(note, duration);
    } else {
      nativeInstance!.triggerAttackRelease(note, duration, time);
    }
  }

  void onLoad(void Function() callback) {
    nativeInstance!.on('load', allowInterop(callback));
  }
}

class Instrument extends Tone {
  final tone_js.Instrument? nativeInstance;

  Instrument(this.nativeInstance);

  void triggerAttack(String note, {dynamic delay}) {
    String? time;
    if (delay != null) {
      time = '+$delay';
    }
    if (time == null) {
      nativeInstance!.triggerAttack(note);
    } else {
      nativeInstance!.triggerAttack(note, time);
    }
  }

  void triggerAttackRelease(String note, dynamic duration, {dynamic delay}) {
    String? time;
    if (delay != null) {
      time = '+$delay';
    }
    if (time == null) {
      nativeInstance!.triggerAttackRelease(note, duration);
    } else {
      nativeInstance!.triggerAttackRelease(note, duration, time);
    }
  }
}

class Synth extends Instrument {
  tone_js.Synth? get nativeSynth => nativeInstance as tone_js.Synth?;

  Synth.fromNativeInstance(tone_js.Synth super.nativeInstance);

  Synth()
      : super(js.callConstructor(_toneContext!.nativeInstance.Synth, [])
            as tone_js.Synth?);

  Synth toMaster() {
    return Synth.fromNativeInstance(nativeSynth!.toMaster());
  }
}

ToneContext? _toneContext;

ToneContext? get toneContext =>
    _toneContext ??
    () {
      window.console.warn(
          'toneContext not initialized yet, please call initToneContext first');
      return null;
    }();

final _initLock = Lock();

Future<ToneContext> initToneContext({String? path, bool? debug}) async {
  if (_toneContext == null) {
    await _initLock.synchronized(() async {
      if (_toneContext == null) {
        path = tone_js.toneJsPath(path: path, debug: debug);
        //devPrint(js.context['require']);
        //devPrint(js.context['define']);
        // Tone defined globally?

        void useGlobal() {
          _toneContext = ToneContext._(tone_js.GlobalTone);
        }

        if (js.context['Tone'] != null) {
          // devPrint('Global tone object');
          useGlobal();
        } else if (js.context['require'] != null) {
          Future useRequire() async {
            var completer = Completer();
            tone_js.require([path], allowInterop((tone_js.Tone native) {
              _toneContext = ToneContext._(native);
              completer.complete();
            }));

            await completer.future;
          }

          // devPrint('Using require');
          try {
            await useRequire();
          } catch (_) {
            /*
            devPrint('Loading js');
            await tone_js.loadToneJs(path: path);
            await _useRequire();
            */
          }
        } else {
          // devPrint('Loading global js');
          await tone_js.loadToneJs(path: path);
          useGlobal();
        }
        // devPrint(_toneContext.nativeInstance.version);

        /*
        await tone_js.loadToneJs();
        await Future.delayed(Duration(milliseconds: 5500));
        _toneContext = ToneContext._();
        */
      }
    });
  }
  return _toneContext!;
}
