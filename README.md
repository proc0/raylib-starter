# RayStart

Raylib C++ Starter Project

## Quick Start (Desktop Debug)

1. **clone** this repo
2. **rename** directory to project name
3. **navigate** into root folder
   a. make build script executable (\*nix only)
4. **run** build script

#### \*nix

```bash
git clone --depth=1 https://github.com/proc0/raystart.git
move raystart mygame
cd mygame
chmod +x ./build.sh
./build.sh
```

#### Windows

```shell
git clone --depth=1 https://github.com/proc0/raystart.git
ren raystart mygame
cd mygame
.\build.ps1
```

Sample Output:

<pre>
-- Generating done (0.0s)
-- Build files have been written to: C:/Users/User/Source/raystart/build
-- Host System: Windows
--
-- Windows Desktop Debug Build
--
-- Using local Raylib: C:/raylib/raylib/src
-- Configuring done (0.3s)
-- Generating done (0.0s)
-- Build files have been written to: C:/Users/User/Source/raystart/build
[ 33%] Building CXX object CMakeFiles/raystart.dir/src/game.cpp.obj
[ 66%] Building CXX object CMakeFiles/raystart.dir/src/main.cpp.obj
[100%] Linking CXX executable raystart.exe
[100%] Built target raystart
</pre>

This builds a _Desktop Debug_ version for the target platform.
Now just run the executable from the build folder.

`./build/raystart` or `.\build\raystart.exe`

## Features

- Multiple ways to use Raylib
  - Use a local build
  - Fetch and build from source
  - Fetch and build a custom build (WIP)
- Flexible build configuration
  - Change folder names easily
  - Add build info in config file for use in source code
- Supports mulitple platforms and target
  - Windows, MacOS, Linux
  - Desktop, Web (with Emscripten)
- Simple build script

## Requirements

- Windows
  - [w64devkit](https://github.com/skeeto/w64devkit)
  - [CMake](https://cmake.org)
  - [Emscripten](https://emscripten.org)
- Linux (WIP)
  - g++
  - make
  - [CMake](https://cmake.org)
- Mac (WIP)
  - g++
  - make
  - [CMake](https://cmake.org)

## Resources

- [Raylib](https://github.com/raysan5/raylib)
- [Raylib built for web](<https://github.com/raysan5/raylib/wiki/Working-for-Web-(HTML5)>)

## Folder structure

<pre>
my-project
├───assets    # project assets
├───build     # build folder
├───build-web # web build folder
├───dist      # install folder
├───dist-web  # web install folder
├───include   # header files
└───src       # source files
</pre>

## Build Script Usage

<pre>
build{.sh|.bat} [--web] [--release] [--run] [OPTIONS]

--web: build for web using Emscripten
--release: build for release
--run: run executable after build
OPTIONS: additional options given to CMake build command
</pre>
