#!/usr/bin/env bash

DIR_BUILD=build
DIR_BUILD_WEB=build-web
PLATFORM=Desktop
BUILD_TYPE=Debug

command -v cmake >/dev/null 2>&1 || { echo >&2 "CMake is not installed or not in the PATH. Please install CMake and add it to your PATH."; exit 1; }

# TODO: forward args to cmake like build.bat
for arg in "$@"
do
  if [ "$arg" == "--web" ]; then
    PLATFORM=Web
  fi
done

if [ "$PLATFORM" = "Web" ]; then
  echo Building for Web...

  if [ ! -d "$DIR_BUILD_WEB" ]; then
    mkdir $DIR_BUILD_WEB
    emcmake cmake -S . -B $DIR_BUILD_WEB
  fi

  cmake $DIR_BUILD_WEB -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DPLATFORM=$PLATFORM
  cmake --build $DIR_BUILD_WEB

  # cmake --install $DIR_BUILD_WEB
else
  echo Building for Desktop...

  if [ ! -d "$DIR_BUILD" ]; then
    mkdir $DIR_BUILD
    cmake -S . -B $DIR_BUILD -G "Unix Makefiles"
  fi

  cmake $DIR_BUILD -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DPLATFORM=$PLATFORM
  cmake --build $DIR_BUILD

  # cmake --install $DIR_BUILD
fi
