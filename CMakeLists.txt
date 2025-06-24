cmake_minimum_required(VERSION 3.18)
set(CMAKE_CXX_STANDARD 17)

# Settings
set(PROJECT_NAME "RaylibStarter")
set(PROJECT_VERSION "0.0.1")
## Project directories relative to root
set(DIR_SOURCE "source")
set(DIR_INCLUDE "include")
set(DIR_RESOURCE "resource")
set(DIR_INSTALL "bin")
set(DIR_INSTALL_WEB "web")
## Optional config file inside of include directory
set(FILE_CONFIG "config")

## Dependencies absolute paths
set(LOCAL_RAYLIB "C:/raylib/raylib/src")
set(LOCAL_RAYLIB_WEB "C:/raylib/raylib/src/web")

# Default flags
set(DEFAULT_DEBUG 1)

if(WIN32)
    set(DEFAULT_PLATFORM WINDOWS)
elseif(MACOS)
    set(DEFAULT_PLATFORM MACOS)
else()
    set(DEFAULT_PLATFORM LINUX)
endif()

# Project definition, source and include files
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} DESCRIPTION ${PROJECT_NAME} LANGUAGES CXX)
file(GLOB_RECURSE DIR_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${DIR_SOURCE}/*.cpp")
set(DIR_INCLUDES "${CMAKE_CURRENT_LIST_DIR}/${DIR_INCLUDE}")

# Compile definition
add_executable(${PROJECT_NAME})
target_sources(${PROJECT_NAME} PRIVATE ${DIR_SOURCES})
target_include_directories(${PROJECT_NAME} PRIVATE ${DIR_INCLUDES})
target_compile_definitions(${PROJECT_NAME} PRIVATE DEBUG_BUILD=${DEFAULT_DEBUG})
target_compile_definitions(${PROJECT_NAME} PRIVATE PLATFORM=${DEFAULT_PLATFORM})

# Local static Raylib
if(PLATFORM STREQUAL WEB)
    message(STATUS "Configuring Raylib for Web")
    find_library(PATH_RAYLIB_WEB raylib PATHS "${LOCAL_RAYLIB_WEB}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)
    message(STATUS "Using Raylib: ${PATH_RAYLIB_WEB}")

    add_library(raylib STATIC IMPORTED)
    set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${PATH_RAYLIB_WEB}")
    target_link_libraries(${PROJECT_NAME} raylib)
    target_include_directories(${PROJECT_NAME} PRIVATE "${LOCAL_RAYLIB}" PRIVATE "C:/emsdk/upstream/emscripten/cache/sysroot/include/emscripten")

    set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".html")
    target_compile_definitions(${PROJECT_NAME} PRIVATE PLATFORM_WEB)
    target_compile_options(${PROJECT_NAME} PRIVATE 
        -Os 
        -Wall
        -Wpedantic
        -Wno-missing-braces
        -Wunused-result
    )
    target_link_options(${PROJECT_NAME} PRIVATE 
        -sFULL_ES3 # requires Raylib to be compiled for Web with OpenGL ES3
        -sASYNCIFY
        -sWASM=1 
        -sTOTAL_MEMORY=67108864 
        -sFORCE_FILESYSTEM=1 
        -sEXPORTED_RUNTIME_METHODS=ccall,cwrap,HEAPF32 
        --preload-file "../${DIR_RESOURCE}" 
        --shell-file "${LOCAL_RAYLIB}/shell.html" 
        --emrun
    )
else()
    message(STATUS "Configuring Raylib for Windows")
    find_library(PATH_RAYLIB raylib PATHS "${LOCAL_RAYLIB}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)
    message(STATUS "Using Raylib: ${PATH_RAYLIB}")

    add_library(raylib STATIC IMPORTED)
    set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${PATH_RAYLIB}")
    target_link_libraries(${PROJECT_NAME} raylib winmm)
endif()

# Get current date
execute_process(COMMAND date "+%Y-%m-%d %H:%M:%S" OUTPUT_VARIABLE OUTPUT_DATE)
string(STRIP "${OUTPUT_DATE}" DATE_BUILD)

# Debug placeholder
if(DEBUG_BUILD)
    message(STATUS "Debug mode is ON")
endif()

# Preprocess config file macros if file exists
set(PATH_CONFIG "${CMAKE_CURRENT_LIST_DIR}/${DIR_INCLUDE}/${FILE_CONFIG}")
if(EXISTS "${PATH_CONFIG}.h.in")
    configure_file("${PATH_CONFIG}.h.in" "${PATH_CONFIG}.h")
endif()

# Create build folder
if(PLATFORM STREQUAL WEB)
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${DIR_INSTALL_WEB}")
else()
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${DIR_INSTALL}")
endif()

install(TARGETS ${PROJECT_NAME} DESTINATION "${PATH_BUILD}")
