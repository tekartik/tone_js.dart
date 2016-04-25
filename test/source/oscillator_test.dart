/*define(["Tone/component/Volume", "helper/Basic", "helper/Meter", "Test",
"Tone/signal/Signal", "helper/PassAudio", "helper/PassAudioStereo"],
function (Volume, Basic, Meter, Test, Signal, PassAudio, PassAudioStereo) {
*/
@TestOn("browser")
import '../common/test_import.dart';

main() {
  group('source/oscillator', () {
    setUpAll(toneJsSetup);

    group('get/set', () {
      test("can be set with an options object", () {
        var osc = new Oscillator();
        osc.set(new OscillatorOptions(
            volume: -10, frequency: 231, detune: -21, type: "square"));
        expect(osc.get().volume, closeTo(-10, 0.1));
        expect(osc.get().frequency, equals(231));
        expect(osc.frequency.value, equals(231));
        expect(osc.get().detune, equals(-21));
        expect(osc.detune.value, equals(-21));
        expect(osc.get().type, equals("square"));
        expect(osc.type, equals("square"));
        osc.dispose();
      });

      test("can be get the values as an object", () {
        var osc = new Oscillator(450, "square");
        expect(osc.get().frequency, equals(450));
        expect(osc.get().type, equals("square"));
        osc.dispose();
      });
    });
  });
}
/*
define(["helper/Basic", "Tone/source/Oscillator", "helper/Offline", "helper/SourceTests",
	"helper/OscillatorTests", "helper/OutputAudio", "Tone/core/Transport"],
	function (BasicTests, Oscillator, Offline, SourceTests, OscillatorTests, OutputAudio, Transport) {

	describe("Oscillator", function(){

		//run the common tests
		BasicTests(Oscillator);
		SourceTests(Oscillator);
		OscillatorTests(Oscillator);

		context("Get/Set", function(){


			it("can be get the values as an object", function(){
				var osc = new Oscillator(450, "square");
				expect(osc.get().frequency).to.equal(450);
				expect(osc.get().type).to.equal("square");
				osc.dispose();
			});


		});

		context("Phase Rotation", function(){
			it ("can change the phase to 90", function(done){
				var instance;
				var offline = new Offline(1);
				offline.before(function(dest){
					instance = new Oscillator({
						"phase" : 90,
						"frequency" : 1
					});
					instance.connect(dest);
					instance.start(0);
				});
				offline.test(function(sample, time){
					if (time < 0.25){
						expect(sample).to.be.within(-1, 0);
					} else if (time < 0.5){
						expect(sample).to.be.within(0, 1);
					}
				});
				offline.after(function(){
					instance.dispose();
					done();
				});
				offline.run();
			});

			it ("can change the phase to -90", function(done){
				var instance;
				var offline = new Offline(1);
				offline.before(function(dest){
					instance = new Oscillator({
						"phase" : 270,
						"frequency" : 1
					});
					instance.connect(dest);
					instance.start(0);
				});
				offline.test(function(sample, time){
					if (time < 0.25){
						expect(sample).to.be.within(0, 1);
					} else if (time < 0.5){
						expect(sample).to.be.within(-1, 0);
					}
				});
				offline.after(function(){
					instance.dispose();
					done();
				});
				offline.run();
			});

		});

		context("Type", function(){

			it ("can get and set the type", function(){
				var osc = new Oscillator({
					"type" : "sawtooth",
				});
				expect(osc.type).to.equal("sawtooth");
				osc.dispose();
			});

			it ("handles 4 basic types", function(){
				var osc = new Oscillator();
				var types = ["triangle", "sawtooth", "sine", "square"];
				for (var i = 0; i < types.length; i++){
					osc.type = types[i];
					expect(osc.type).to.equal(types[i]);
				}
				osc.dispose();
			});

			it ("throws an error if invalid type is set", function(){
				var osc = new Oscillator();
				expect(function(){
					osc.type = "invalid";
				}).to.throw(Error);
				osc.dispose();
			});

			it ("can set extended types", function(){
				var osc = new Oscillator();
				osc.type = "sine5";
				expect(osc.type).to.equal("sine5");
				osc.type = "triangle2";
				expect(osc.type).to.equal("triangle2");
				osc.dispose();
			});
		});

		context("Partials", function(){

			it ("can pass partials in the constructor", function(){
				var osc = new Oscillator({
					"partials" : [1, 0.3, 0.3],
					"type" : "custom"
				});
				expect(osc.type).to.equal("custom");
				expect(osc.partials[1]).to.equal(0.3);
				osc.dispose();
			});

			it ("can set partials", function(){
				var osc = new Oscillator();
				osc.partials = [1, 0.2, 0.2, 0.2];
				expect(osc.type).to.equal("custom");
				expect(osc.partials[1]).to.equal(0.2);
				osc.dispose();
			});

			it ("makes a sound with custom partials", function(done){
				var osc;
				OutputAudio(function(dest){
					osc = new Oscillator().connect(dest).start();
					osc.partials = [1, 0.2, 0.2, 0.2];
				}, function(){
					osc.dispose();
					done();
				});
			});

			it ("outputs empty array when type is not 'custom'", function(){
				var osc = new Oscillator({
					"partials" : [1, 0.3, 0.3],
					"type" : "custom"
				});
				expect(osc.type).to.equal("custom");
				expect(osc.partials[1]).to.equal(0.3);
				osc.type = "sine2";
				expect(osc.type).to.equal("sine2");
				expect(osc.partials.length).to.equal(0);
				osc.dispose();
			});

		});

		context("Synchronization", function(){
			it("can sync the frequency to the Transport", function(done){
				var osc;
				var offline = new Offline(0.1);
				offline.before(function(dest){
					Transport.bpm.value = 120;
					osc = new Oscillator(2);
					osc.frequency.connect(dest);
					osc.syncFrequency();
					Transport.bpm.value = 240;
				});
				offline.test(function(freq){
					expect(freq).to.be.closeTo(4, 0.001);
				});
				offline.after(function(){
					Transport.bpm.value = 120;
					osc.dispose();
					done();
				});
				offline.run();
			});

			it("can unsync the frequency from the Transport", function(done){
				var osc;
				var offline = new Offline(0.1);
				offline.before(function(dest){
					Transport.bpm.value = 120;
					osc = new Oscillator(2);
					osc.frequency.connect(dest);
					osc.syncFrequency();
					Transport.bpm.value = 240;
					osc.unsyncFrequency();
				});
				offline.test(function(freq){
					expect(freq).to.be.closeTo(2, 0.001);
				});
				offline.after(function(){
					Transport.bpm.value = 120;
					osc.dispose();
					done();
				});
				offline.run();
			});
		});

	});
});
 */
