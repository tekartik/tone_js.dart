#!/bin/bash

# Fast fail the script on failures.
set -ex

dartanalyzer --fatal-warnings example lib test
pub run test -p vm,firefox
pub run build_runner test -- -p vm,firefox