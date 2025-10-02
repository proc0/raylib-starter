# Raylib Starter

Raylib C++ Starter Project

## Quick Start (Desktop Debug)

1. **clone** this repo
2. **rename** directory to project name
3. **navigate** into root folder
   a. make build script executable (\*nix)
4. **run** build script

#### \*nix

```bash
git clone --depth=1 https://github.com/proc0/raylib-starter.git
move raylib-starter my-project
cd my-project
chmod +x ./build.sh
./build.sh
```

#### Windows

```Batch
git clone --depth=1 https://github.com/proc0/raylib-starter.git
ren raylib-starter my-project
cd my-project
.\build.bat
```

## Features

- CMake config
  - Change folder names easily
  - Static linking of Raylib (future: adding FetchContent)
  - Config file with some reflexive variables like version and debug mode
- Compiles with MinGW Makefiles on Windows
  - C++ 20
- Compiles with Emscripten on Windows
- Includes script for easily invoking build step
- Includes some basic .vscode configuration
- Future support for SublimeText, maybe NeoVim

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

build{.sh|.bat} [--web] [--release] [--run] [<options>]

--web: build for web using Emscripten
--release: build for release
--run: run executable after build
<options>: additional options given to CMake build command
