#!/bin/bash
set -e

NAME="libABBackgroundManager.dylib"
SDK=$(xcrun --sdk iphoneos --show-sdk-path)

mkdir -p build

xcrun --sdk iphoneos clang \
  -arch arm64 \
  -isysroot "$SDK" \
  -miphoneos-version-min=15.0 \
  -fobjc-arc \
  -fmodules \
  -dynamiclib \
  Sources/ABBackgroundManager.m \
  -framework Foundation \
  -framework UIKit \
  -install_name "@rpath/$NAME" \
  -o "build/$NAME"

file "build/$NAME"
