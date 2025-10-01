cmake_minimum_required(VERSION 3.22)
set(CMAKE_CXX_STANDARD 20)

#                         PROJECT
#═══════════════════════════════════════════════════════════════
# TODO: add automatic versioning with git push to main
set(PROJECT_VERSION "0.0.1")
get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} DESCRIPTION ${PROJECT_NAME} LANGUAGES CXX)

#                         SETTINGS
#═══════════════════════════════════════════════════════════════
set(DIR_SOURCE "src" CACHE STRING "Project source files folder name")
set(DIR_INCLUDE "include" CACHE STRING "Project header files folder name")
set(DIR_ASSETS "assets" CACHE STRING "Project assets folder name")
set(DIR_INSTALL "dist" CACHE STRING "Project install folder name")
set(DIR_PUBLISH "web" CACHE STRING "Project web install folder name")
set(FILE_CONFIG "config" CACHE STRING "Optional config file name")

# Raylib settings - ONLY ONE SHOULD BE ON
option(USE_RAYLIB_FETCH "Fetch and build from source" OFF)
option(USE_RAYLIB_CUSTOM "Fetch and custom build" OFF)
option(USE_RAYLIB_LOCAL "Find and use a local build" ON)
# Local Raylib paths 
set(LOCAL_RAYLIB "C:/raylib/raylib/src")
set(LOCAL_RAYLIB_WEB "C:/raylib/raylib/src/web")
# Local Raylib Web - Emscripten build include path
set(LOCAL_EM_INCLUDE "C:/emsdk/upstream/emscripten/cache/sysroot/include/emscripten")

#                        REFLECTION
#═══════════════════════════════════════════════════════════════

# Build type flags
set(BUILD_DEBUG OFF)
set(BUILD_RELEASE OFF)
set(BUILD_DESKTOP OFF)
set(BUILD_WEB OFF)
# Config file specific flags
set(IS_DEBUG 0)

if(BUILD_TYPE STREQUAL Debug)
    set(BUILD_DEBUG ON)
    set(IS_DEBUG 1)
endif()

if(PLATFORM STREQUAL Desktop)
    set(BUILD_DESKTOP ON)
endif()

if(PLATFORM STREQUAL Web)
    set(BUILD_WEB ON)
endif()

if(WIN32)
    set(OS Windows)
elseif(MACOS)
    set(OS MacOS)
else()
    set(OS Linux)
endif()

message(STATUS "\n-- ${OS} ${PLATFORM} ${BUILD_TYPE} Build \n--")

#                         DEFINITION
#═══════════════════════════════════════════════════════════════
add_executable(${PROJECT_NAME})
# source files
file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${DIR_SOURCE}/*.cpp")
target_sources(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCES})
# include files
set(PROJECT_INCLUDES "${CMAKE_CURRENT_LIST_DIR}/${DIR_INCLUDE}")
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_INCLUDES})

#                           RAYLIB
#═══════════════════════════════════════════════════════════════

# Local Raylib Desktop
if(USE_RAYLIB_LOCAL AND BUILD_DESKTOP)
    if(EXISTS "${LOCAL_RAYLIB}")
        message(STATUS "Using local Raylib: ${LOCAL_RAYLIB}")
    else()
        message(FATAL_ERROR "SETTINGS ERROR: Local Raylib path: ${LOCAL_RAYLIB} does not exist!")
    endif()

    find_library(PATH_RAYLIB raylib PATHS "${LOCAL_RAYLIB}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)

    add_library(raylib STATIC IMPORTED)
    set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${PATH_RAYLIB}")

    if(OS STREQUAL Windows)
        target_link_libraries(${PROJECT_NAME} raylib winmm)
    else()
        target_link_libraries(${PROJECT_NAME} raylib)
    endif()
endif()

# Local Raylib Web
if(USE_RAYLIB_LOCAL AND BUILD_WEB)
    find_library(PATH_RAYLIB_WEB raylib_web PATHS "${LOCAL_RAYLIB_WEB}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)
    message(STATUS "Using Raylib: ${PATH_RAYLIB_WEB}")

    add_library(raylib_web STATIC IMPORTED)
    set_target_properties(raylib_web PROPERTIES IMPORTED_LOCATION "${PATH_RAYLIB_WEB}")
    set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".html")

    target_include_directories(${PROJECT_NAME} PRIVATE "${LOCAL_RAYLIB}" PRIVATE "${LOCAL_EM_INCLUDE}")

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
        # -sUSE_GLFW=3 
        -sASYNCIFY
        -sWASM=1 
        -sEXPORT_ES6=1
        -sTOTAL_MEMORY=67108864 
        -sFORCE_FILESYSTEM=1 
        -sEXPORTED_RUNTIME_METHODS=ccall,cwrap,HEAPF32 
        --preload-file "../${DIR_ASSETS}" 
        --shell-file "${LOCAL_RAYLIB}/shell.html" 
        --emrun
    )
    target_link_libraries(${PROJECT_NAME} raylib_web)
endif()

#                         METADATA
#═══════════════════════════════════════════════════════════════
# Get current datetime
execute_process(COMMAND date "+%Y-%m-%d %H:%M:%S" OUTPUT_VARIABLE OUTPUT_DATE)
string(STRIP "${OUTPUT_DATE}" DATE_BUILD)

# Preprocess config file macros if file exists
set(PATH_CONFIG "${CMAKE_CURRENT_LIST_DIR}/${DIR_INCLUDE}/${FILE_CONFIG}")
if(EXISTS "${PATH_CONFIG}.h.in")
    configure_file("${PATH_CONFIG}.h.in" "${PATH_CONFIG}.h")
endif()

#                         INSTALL
#═══════════════════════════════════════════════════════════════
# Set build folder
if(BUILD_DESKTOP)
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${DIR_INSTALL}")
endif()

if(BUILD_WEB)
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${DIR_PUBLISH}")
endif()
# Install files
install(TARGETS ${PROJECT_NAME} DESTINATION "${PATH_BUILD}")
