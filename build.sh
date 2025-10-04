#!/usr/bin/env bash

command -v cmake >/dev/null 2>&1 || { echo >&2 "CMake is not installed or not in the PATH. Please install CMake and add it to your PATH."; exit 1; }

APP_NAME="${PWD##*/}"
PLATFORM=Desktop
BUILD_TYPE=Debug
BUILD_PATH=build
SHOULD_RUN=false
GENERATOR="Unix Makefiles"

for arg in "$@"
do
  if [ "$arg" == "--web" ]; then
    command -v em++ >/dev/null 2>&1 || { echo >&2 "Emscripten is not installed or not in the PATH. Please install Emscripten to build for Web."; exit 1; }
    PLATFORM=Web
    BUILD_PATH=$BUILD_PATH-web
    shift
  elif [ "$arg" == "--release" ]; then
    PLATFORM=Release
  elif [ "$arg" == "--run" ]; then
    SHOULD_RUN=true
  fi
done

# Configure
if [ ! -d "$BUILD_PATH" ]; then
  if [ "$PLATFORM" = "Web" ]; then
    emcmake cmake -S . -B $BUILD_PATH -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DPLATFORM=$PLATFORM
  else
    cmake -S . -B $BUILD_PATH -G "$GENERATOR" -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DPLATFORM=$PLATFORM
  fi
fi

# Generate
cmake $BUILD_PATH -DPLATFORM=$PLATFORM -DCMAKE_BUILD_TYPE=$BUILD_TYPE

# Build
cmake --build $BUILD_PATH "$@"

# Install
# cmake --install $BUILD_PATH

# Run
if [[ "$SHOULD_RUN" == "true" ]]; then
    emrun $BUILD_PATH/$APP_NAME.html
else
    ./$BUILD_PATH/$APP_NAME
fi