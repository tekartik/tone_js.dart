/*define(["Tone/component/Volume", "helper/Basic", "helper/Meter", "Test",
"Tone/signal/Signal", "helper/PassAudio", "helper/PassAudioStereo"],
function (Volume, Basic, Meter, Test, Signal, PassAudio, PassAudioStereo) {
*/
@TestOn("browser")
import '../common/test_import.dart';

main() {
  group('component/volume', () {
    setUpAll(toneJsSetup);

    test("handles input and output connections", () {
      var vol = new Volume();
      Test test = createTest();
      connectTest(test, vol);
      vol.connect(test);
      vol.dispose();
    });

    test("can be constructed with volume value", () {
      var vol = new Volume(-12);
      expect(vol.volume.value, closeTo(-12, 0.1));
      vol.dispose();
    });

    test("can be constructed with an options object", () {
      var vol = new Volume(new VolumeOptions(volume: 2));

      expect(vol.volume.value, closeTo(2, 0.1));
      vol.dispose();
    });

    test("can set/get with an object", () {
      var vol = new Volume();
      vol.set(new VolumeOptions(volume: -10));
      expect(vol.get().volume, closeTo(-10, 0.1));
      vol.dispose();
    });
/*
  it("passes the incoming signal through", function(done){
  var vol;
  PassAudio(function(input, output){
  vol = new Volume();
  input.connect(vol);
  vol.connect(output);
  }, function(){
  vol.dispose();
  done();
  });
  });

  it("passes the incoming stereo signal through", function(done){
  var vol;
  PassAudioStereo(function(input, output){
  vol = new Volume();
  input.connect(vol);
  vol.connect(output);
  }, function(){
  vol.dispose();
  done();
  });
  });

  it("can lower the volume", function(done){
  var vol;
  var signal;
  var meter = new Meter();
  meter.before(function(output){
  vol = new Volume(-10).connect(output);
  signal = new Signal(1).connect(vol);
  });
  meter.test(function(level){
  expect(level).to.be.closeTo(vol.dbToGain(-10), 0.01);
  });
  meter.after(function(){
  vol.dispose();
  signal.dispose();
  done();
  });
  meter.run();
  });

  });
  });
  */
  });
}
