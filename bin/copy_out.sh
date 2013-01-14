#!/bin/bash -x
OUT_DIR=example/component
rm -rf $OUT_DIR
mkdir -p $OUT_DIR
find web/out -maxdepth 1 -type f -print0 | xargs -0 -J % cp % $OUT_DIR
rm $OUT_DIR/*.dart
