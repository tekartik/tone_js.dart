import 'js_interop.dart' as tonejs;
import 'tone.dart';

class Instrument extends Tone {
  final tonejs.InstrumentJs _instrumentJs;

  Instrument(this._instrumentJs);
}

extension InstrumentPrvExt on Instrument {
  tonejs.InstrumentJs get instrumentJs => _instrumentJs;
}
