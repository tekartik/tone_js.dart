library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:synchronized/synchronized.dart';
import 'package:tekartik_tone_js/src/js_interop.dart';
import 'package:tekartik_tone_js/tone.dart';
import 'package:tekartik_tone_js/tone_js_loader.dart' as tone_js;

import 'js_interop.dart' as tonejs;

class ToneGainNode {
  final tonejs.GainNodeJs _gainNodeJs;

  ToneGainNode(this._gainNodeJs);

  void connect(JSAny node, int i, [int? inputNumber]) =>
      _gainNodeJs.connect(node, i.toJS, inputNumber?.toJS);

  void disconnect([JSAny? node]) => _gainNodeJs.disconnect(node);
}

class ToneAudioContext {
  final tonejs.AudioContextJs _audioContextJs;

  ToneAudioContext(this._audioContextJs);

  ToneGainNode createGain() => ToneGainNode(_audioContextJs.createGain());
}

class ToneContext {
  final tonejs.ToneJs _toneJs;

  ToneContext._(this._toneJs);

  String get version => _toneJs.version;

  ToneAudioContext get context => ToneAudioContext(_toneJs.context);

  Synth newSynth() {
    return Synth.fromNativeInstance(_toneJs.newSynth());
  }

  Future<Sampler> createSampler(Map<String, String> samples,
      {String? baseUrl}) async {
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
    var samplerJs = toneContext.toneJs.newSampler(jsObject, options);
    await completer.future;
    var sampler = Sampler.fromNativeInstance(samplerJs);

    return sampler;
  }
}

class Tone {}

ToneContext? _toneContext;

ToneContext? get toneContextOrNull =>
    _toneContext ??
    () {
      // ignore: avoid_print
      print(
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
          _toneContext = ToneContext._(globalToneJsOrNull!);
        }

        Future<void> loadAndUseGlobal() async {
          await tone_js.loadToneJs(path: path);
          useGlobal();
        }

        // devPrint('globalToneJsOrNull $globalToneJsOrNull');
        // devPrint('globalRequireOrNull $globalRequireOrNull');

        if (globalToneJsOrNull != null) {
          // devPrint('Global tone object');
          useGlobal();
        } else if (globalRequireJsOrNull != null) {
          Future useRequire() async {
            var completer = Completer<void>();
            var onLoad = (tonejs.ToneJs toneJs) {
              _toneContext = ToneContext._(toneJs);
              completer.complete();
            }.toJS;
            requireJs([path!].map((e) => e.toJS).toList().toJS, onLoad);
            //_toneContext = ToneContext._(native, globalToneJsOrNull!);
            //completer.complete();

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
  tonejs.ToneJs get toneJs => _toneJs;
}
