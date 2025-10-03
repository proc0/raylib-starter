#!/usr/bin/env bash

command -v cmake >/dev/null 2>&1 || { echo >&2 "CMake is not installed or not in the PATH. Please install CMake and add it to your PATH."; exit 1; }

PLATFORM=Desktop
BUILD_TYPE=Debug
BUILD_PATH=build
GENERATOR="Unix Makefiles"

for arg in "$@"
do
  if [ "$arg" == "--web" ]; then
    PLATFORM=Web
    BUILD_PATH=$BUILD_PATH-web
    shift
  elif [ "$arg" == "--release" ]; then
    PLATFORM=Release
  fi
done

# Configure
if [ ! -d "$BUILD_PATH" ]; then
  if [ "$PLATFORM" = "Web" ]; then
    emcmake cmake -S . -B $BUILD_PATH -DCMAKE_BUILD_TYPE=$BUILD_TYPE
  else
    cmake -S . -B $BUILD_PATH -G "$GENERATOR" -DCMAKE_BUILD_TYPE=$BUILD_TYPE
  fi
fi

# Generate
cmake $BUILD_PATH -DPLATFORM=$PLATFORM -DCMAKE_BUILD_TYPE=$BUILD_TYPE

# Build
cmake --build $BUILD_PATH "$@"

# Install
# cmake --install $BUILD_PATH
