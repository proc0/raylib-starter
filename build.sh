#!/usr/bin/bash

# get args and check for --web
web=false
for arg in "$@"
do
  if [ "$arg" == "--web" ]; then
    web=true
  fi
done

if [ "$web" = true ]; then
  if [ ! -d "build-web" ]; then
    mkdir build-web
    emcmake cmake -S . -B build-web
  fi

  cmake build-web
  cmake --build build-web
  # cmake --install build-web
else

  if [ ! -d "build" ]; then
    mkdir build
    cmake -S . -B build -G "Unix Makefiles"
  fi

  cmake build
  cmake --build build
  # cmake --install build
fi

