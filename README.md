# Raylib Starter

A simple starter C++ repo with Raylib and CMake
(future support for other languages and other libs)

## Features

- CMake config
  - Change folder names easily
  - Static linking of Raylib (future: adding FetchContent)
  - Config file with some reflexive variables like version and debug mode
- Compiles with MinGW Makefiles on Windows
  - C++ 17 (future: add easy way to change standards including C)
- Includes script for easily invoking build step
- Includes some basic .vscode configuration
- Future support for SublimeText, maybe NeoVim

## Requirements

- Windows
  - [w64devkit](https://github.com/skeeto/w64devkit)
  - [CMake](https://cmake.org)
- Linux (future)
  - probably ready to go but have not tested yet
- Mac (future)

## Usage

Clone, change the directory name, and cd into it

```
git clone https://github.com/proc0/raylib-starter.git
move raylib-starter my-project
cd my-project
```

Run the build script
On Windows

```
.\build.bat
```

On Linux

```
chmod +x ./build.sh
./build.sh
```

## Folder structure

├───.vscode
├───bin # executables
├───cmake # cmake build cache files
│ └───CMakeFiles ...
├───include # header files
├───resource # assets
└───source # source files
