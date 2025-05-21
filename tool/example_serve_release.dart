import 'dart:async';

import 'package:tekartik_build_utils/webdev/webdev.dart';

Future main() async {
  await serve(['example:8060', '--release', '--auto=refresh']);
}
