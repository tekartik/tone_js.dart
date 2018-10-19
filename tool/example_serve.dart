import 'dart:async';

import 'package:tekartik_build_utils/webdev/webdev.dart';

Future main() async {
  await serve([
    'example:8060',
    "dev_menu:8061",
    "--live-reload",
  ]);
}
