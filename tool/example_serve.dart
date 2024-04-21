import 'dart:async';

import 'package:tekartik_build_utils/webdev/webdev.dart';

Future main() async {
  var port = 8060;
  // ignore: avoid_print
  print('http://localhost:$port/tone_example.html');
  await serve([
    'example:$port',
    '--auto=refresh',
  ]);
}
