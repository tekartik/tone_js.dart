#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings \
  lib/tone_js.dart \
  lib/tone_js_loader.dart

pub run test -p vm,firefox