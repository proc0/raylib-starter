#!/usr/bin/bash

if [ ! -d "cmake" ]; then
  cmake -S . -B cmake -G "Unix Makefiles"
fi

cmake cmake
cmake --build cmake
cmake --install cmake
