import 'js_interop.dart' as tonejs;
import 'js_interop_compat.dart' as tone_js;
import 'tone.dart';

class Instrument extends Tone {
  final tonejs.InstrumentJs _instrumentJs;
  final tone_js.Instrument _nativeInstance;

  Instrument(this._nativeInstance, this._instrumentJs);
}

extension InstrumentPrvExt on Instrument {
  tonejs.InstrumentJs get instrumentJs => _instrumentJs;
  tone_js.Instrument get nativeInstance => _nativeInstance;
}
