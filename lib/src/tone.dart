library tekartik_tone;

import 'dart:html';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:js/js_util.dart' as js;
import 'package:tekartik_browser_utils/browser_utils_import.dart';
import 'package:tekartik_tone_js/src/js_interop.dart';
import 'package:tekartik_tone_js/tone.dart';
import 'package:tekartik_tone_js/tone_js_loader.dart' as tone_js;

import 'js_interop.dart' as tonejs;
import 'js_interop_compat.dart' as tone_js;

class ToneContext {
  final tone_js.Tone _nativeInstance;
  final tonejs.ToneJs _toneJs;

  ToneContext._(this._nativeInstance, this._toneJs);

  String get version => nativeInstance.version;

  tone_js.AudioContext get context => nativeInstance.context;

  Synth newSynth() {
    return Synth.fromNativeInstance(
        js.callConstructor(toneContext.nativeInstance.Synth, []),
        _toneJs.newSynth());
  }

  Future<Sampler> createSampler(Map<String, String> samples,
      {String? baseUrl}) async {
    late tone_js.Sampler nativeSampler;
    late tonejs.SamplerJs samplerJs;
    {
      var completer = Completer<void>();
      Object? mapToJSObj(Map<String, String> a) {
        var object = js.newObject<Object>();
        a.forEach((k, v) {
          var key = k;
          var value = v;
          js.setProperty(object, key, value);
        });
        return object;
      }

      var onLoad = allowInterop(([buffers]) {
        // devPrint('Sampler loaded $_buffers');
        completer.complete();
      });
      // devPrint('constructing Sample');
      nativeSampler = js.callConstructor(nativeInstance.Sampler, [
        mapToJSObj(samples),
        if (baseUrl != null)
          tone_js.SamplerOptions(onload: onLoad, baseUrl: baseUrl)
        else
          tone_js.SamplerOptions(onload: onLoad)
      ]) as tone_js.Sampler;
      await completer.future;
    }
    {
      var completer = Completer<void>();
      var jsObject = JSObject();
      var onLoad = ([JSAny? _]) {
        completer.complete();
      }.toJS;
      var options = (baseUrl != null)
          ? tonejs.SamplerOptionsJs(onload: onLoad, baseUrl: baseUrl)
          : tonejs.SamplerOptionsJs(onload: onLoad);
      samples.forEach((key, value) {
        jsObject.setProperty(key.toJS, value.toJS);
      });
      samplerJs = toneContext.toneJs.newSampler(jsObject, options);
      await completer.future;
    }
    var sampler = Sampler.fromNativeInstance(nativeSampler, samplerJs);

    return sampler;
  }
}

class Tone {}

ToneContext? _toneContext;

ToneContext? get toneContextOrNull =>
    _toneContext ??
    () {
      window.console.warn(
          'toneContext not initialized yet, please call initToneContext first');
      return null;
    }();

ToneContext get toneContext => toneContextOrNull!;

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
          _toneContext = ToneContext._(tone_js.GlobalTone, globalToneJsOrNull!);
        }

        Future<void> loadAndUseGlobal() async {
          await tone_js.loadToneJs(path: path);
          useGlobal();
        }

        //devPrint('js.context["Tone"] ${js.context['Tone']}');
        // devPrint('globalToneJsOrNull $globalToneJsOrNull');
        //devPrint('js.context["require"] ${js.context['require']}');
        // devPrint('globalRequireOrNull $globalRequireOrNull');

        if (globalToneJsOrNull != null) {
          // devPrint('Global tone object');
          useGlobal();
        } else if (globalRequireOrNull != null) {
          Future useRequire() async {
            var completer = Completer<void>();
            tone_js.require([path], allowInterop((tone_js.Tone native) {
              devWarning('TODO');
              _toneContext = ToneContext._(native, globalToneJsOrNull!);
              completer.complete();
            }));

            await completer.future;
          }

          try {
            await useRequire();
          } catch (_) {
            await loadAndUseGlobal();
          }
        } else {
          await loadAndUseGlobal();
        }
      }
    });
  }
  return _toneContext!;
}

extension ToneContextPrvExt on ToneContext {
  tone_js.Tone get nativeInstance => _nativeInstance;

  tonejs.ToneJs get toneJs => _toneJs;
}
