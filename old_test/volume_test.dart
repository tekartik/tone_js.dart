/*define(["Tone/component/Volume", "helper/Basic", "helper/Meter", "Test",
"Tone/signal/Signal", "helper/PassAudio", "helper/PassAudioStereo"],
function (Volume, Basic, Meter, Test, Signal, PassAudio, PassAudioStereo) {
*/
@TestOn("browser")
library tekartik_tone_js.test.volume_test;

import 'package:test/test.dart';

import 'common/test_import.dart';

main() {
  group('component/volume', () {
    setUpAll(toneJsSetup);

    /*
    test("handles input and output connections", () async {
      var vol = Volume();
      Test test = await createTest();
      connectTest(test, vol);
      vol.connect(test);
      vol.dispose();
    });

    test("can be constructed with volume value", () {
      var vol = Volume(-12);
      expect(vol.volume.value, closeTo(-12, 0.1));
      vol.dispose();
    });

    test("can be constructed with an options object", () {
      var vol = Volume(VolumeOptions(volume: 2));

      expect(vol.volume.value, closeTo(2, 0.1));
      vol.dispose();
    });

    test("can set/get with an object", () {
      var vol = Volume();
      vol.set(VolumeOptions(volume: -10));
      expect(vol.get().volume, closeTo(-10, 0.1));
      vol.dispose();
    });
    */
  }, skip: true);
}
