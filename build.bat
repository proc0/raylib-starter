@echo off
setlocal enabledelayedexpansion

where cmake >nul 2>nul
if %errorlevel% neq 0 (
    echo CMake is not installed or not in the PATH. Please install CMake and add it to your PATH.
    exit /b 1
)

set "PLATFORM=Desktop"
set "BUILD_TYPE=Debug"
set "BUILD_PATH=build"
set "GENERATOR=MinGW Makefiles"

@REM capture and forward arguments to cmake
set "args="
for %%a in (%*) do (
    if "%%a"=="--web" (
        set "PLATFORM=Web"
        set "BUILD_PATH=%BUILD_PATH%-web"
    ) else (
        if not defined args (
            set "args=%%a"
        ) else (
            set "args=!args! %%a"
        )
    )
)

@REM Configure
if not exist %BUILD_PATH% (
    mkdir %BUILD_PATH%

    if "%PLATFORM%"=="Web" (
        emcmake cmake -S . -B %BUILD_PATH% -DBUILD_TYPE=%BUILD_TYPE%
    ) else (
        cmake -S . -B %BUILD_PATH% -G "%GENERATOR%" -DBUILD_TYPE=%BUILD_TYPE%
    )
)

@REM Generate
cmake %BUILD_PATH% -DBUILD_TYPE=%BUILD_TYPE% -DPLATFORM=%PLATFORM%

@REM Build
if defined args (
    cmake --build %BUILD_PATH% "%args%"
) else (
    cmake --build %BUILD_PATH%
)

@REM cmake --install %BUILD_PATH%
