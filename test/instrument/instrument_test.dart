@TestOn("browser")
import '../common/test_import.dart';

main() {
  group('instrument/instrument', () {
    setUpAll(toneJsSetup);

    test("can be constructed with an options object", () {
      var instr = new Instrument(new InstrumentOptions(volume: -12));
      expect(instr.volume.value, closeTo(-12, 0.1));
      instr.dispose();
    });

    test("can get/set attributes", () {
      var instr = new Instrument();
      instr.set(new InstrumentOptions(volume: 2));
      expect(instr.get().volume, closeTo(2, 0.1));
    });
  });
}
