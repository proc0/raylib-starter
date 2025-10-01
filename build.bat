@echo off
setlocal enabledelayedexpansion

set "DIR_BUILD=build"
set "DIR_BUILD_WEB=build-web"

set "PLATFORM=Desktop"
set "BUILD_TYPE=Debug"
set "GENERATOR=MinGW Makefiles"

where cmake >nul 2>nul
if %errorlevel% neq 0 (
    echo CMake is not installed or not in the PATH. Please install CMake and add it to your PATH.
    exit /b 1
)

@REM capture and forward arguments to cmake
set "args="
for %%a in (%*) do (
    if "%%a"=="--web" (
        set "PLATFORM=Web"
    ) else (
        if not defined args (
            set "args=%%a"
        ) else (
            set "args=!args! %%a"
        )
    )
)

if "%PLATFORM%"=="Web" (
    @REM Building for Web...

    if not exist %DIR_BUILD_WEB% (
        mkdir %DIR_BUILD_WEB%
        emcmake cmake -S . -B %DIR_BUILD_WEB%
    )
    
    cmake %DIR_BUILD_WEB% -DBUILD_TYPE=%BUILD_TYPE% -DPLATFORM=%PLATFORM%
    cmake --build %DIR_BUILD_WEB% --verbose

    @REM cmake --install %DIR_BUILD_WEB%
) else (
    @REM Building for Desktop...

    if not exist %DIR_BUILD% (
        mkdir %DIR_BUILD%
        cmake -S . -B %DIR_BUILD% -G "%GENERATOR%"
    )
    
    cmake %DIR_BUILD% -DBUILD_TYPE=%BUILD_TYPE% -DPLATFORM=%PLATFORM%

    if defined args (
        cmake --build %DIR_BUILD% "%args%"
    ) else (
        cmake --build %DIR_BUILD%
    )
    
    @REM cmake --install %DIR_BUILD%
)
