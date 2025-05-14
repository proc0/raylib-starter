@echo off
setlocal enabledelayedexpansion

set "web_build=false"
for %%a in (%*) do (
    if "%%a"=="--web" (
        set "web_build=true"
    )
)

if "%web_build%"=="true" (
    echo Building for web...
    if not exist build-web (
        mkdir build-web
        emcmake cmake -S . -B build-web
    )
    cmake build-web
    cmake --build build-web --verbose
    @REM cmake --install build-web
) else (
    echo Building for desktop...
    if not exist build (
        cmake -S . -B build -G "MinGW Makefiles"
    )
    
    cmake build
    cmake --build build
    @REM cmake --install build
)



