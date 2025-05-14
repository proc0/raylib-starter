#!/usr/bin/bash

if [ ! -d "cmake" ]; then
  cmake -S . -B build -G "Unix Makefiles"
fi

cmake build
cmake --build build
cmake --install build
