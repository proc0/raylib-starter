cmake_minimum_required(VERSION 3.22)
set(CMAKE_CXX_STANDARD 20)

#                         PROJECT
#═══════════════════════════════════════════════════════════════
set(PROJECT_VERSION "0.1.0")
get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} DESCRIPTION ${PROJECT_NAME} LANGUAGES CXX)

#                         SETTINGS
#═══════════════════════════════════════════════════════════════
set(DIR_SOURCE "src" CACHE STRING "Project source files folder name")
set(DIR_INCLUDE "include" CACHE STRING "Project header files folder name")
set(DIR_ASSETS "assets" CACHE STRING "Project assets folder name")
set(DIR_INSTALL "dist" CACHE STRING "Project install folder name")
set(FILE_CONFIG "config" CACHE STRING "Optional config file name in include folder")

# Raylib settings - ONLY ONE SHOULD BE ON
option(USE_RAYLIB_FETCH "Fetch and build from source" OFF)
option(USE_RAYLIB_CUSTOM "Fetch and custom build" OFF)
option(USE_RAYLIB_LOCAL "Find and use a local build" ON)
# LOCAL BUILD PATHS
message(STATUS "Host System: ${CMAKE_HOST_SYSTEM_NAME}")
# Set paths based on OS
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(OS Windows)
    set(LOCAL_RAYLIB "C:/raylib/raylib/src")
    set(LOCAL_RAYLIB_WEB "C:/raylib/raylib/src/web")
    set(LOCAL_EM_INCLUDE "C:/emsdk/upstream/emscripten/cache/sysroot/include")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(OS MacOS)
    set(LOCAL_RAYLIB "/usr/local/lib/raylib")
    set(LOCAL_RAYLIB_WEB "/usr/local/lib/raylib/web")
    set(LOCAL_EM_INCLUDE "/usr/local/lib/emsdk/upstream/emscripten/cache/sysroot/include")
else()
    set(OS Linux)
    set(LOCAL_RAYLIB "/usr/local/lib/raylib")
    set(LOCAL_RAYLIB_WEB "/usr/local/lib/raylib/web")
    set(LOCAL_EM_INCLUDE "/usr/local/lib/emsdk/upstream/emscripten/cache/sysroot/include")
endif()

#                      BUILD VARIABLES
#═══════════════════════════════════════════════════════════════
# Build type flags
set(IS_DESKTOP OFF)
set(IS_WEB OFF)
set(IS_DEBUG OFF)
set(IS_RELEASE OFF)
# Config file flags
set(DEBUG 0)

if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(IS_DEBUG ON)
    set(DEBUG 1)
elseif(CMAKE_BUILD_TYPE STREQUAL Release)
    set(IS_RELEASE ON)
endif()

if(PLATFORM STREQUAL Desktop)
    set(IS_DESKTOP ON)
elseif(PLATFORM STREQUAL Web)
    set(IS_WEB ON)
endif()

# CMAKE_SYSTEM_NAME will detect Emscripten
message(STATUS "\n-- ${CMAKE_SYSTEM_NAME} ${CMAKE_CXX_COMPILER_ID} ${PLATFORM} ${CMAKE_BUILD_TYPE} Build \n--")

# libraries array
set(LIBRARIES ${PROJECT_NAME})

#                         FUNCTIONS
#═══════════════════════════════════════════════════════════════
include(FetchContent)
function(Fetch lib url tag)
    FetchContent_Declare(${lib}
        GIT_REPOSITORY ${url}
        GIT_TAG        ${tag}
        GIT_SHALLOW    TRUE
        GIT_PROGRESS   TRUE
    )
    FetchContent_MakeAvailable(${lib})

    list(APPEND LIBRARIES ${lib})
endfunction()

#                         DEFINITION
#═══════════════════════════════════════════════════════════════

add_executable(${PROJECT_NAME})
# source files
file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${DIR_SOURCE}/*.cpp")
target_sources(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCES})
# include files
set(PROJECT_INCLUDES "${CMAKE_CURRENT_LIST_DIR}/${DIR_INCLUDE}")
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_INCLUDES})
# compile flags
target_compile_options(${PROJECT_NAME} PRIVATE 
    -Os
    -Wall
    -Wpedantic
    -Wno-missing-braces
    -Wunused-result
)

#                      DEPENDENCY SETUP
#═══════════════════════════════════════════════════════════════

# Fetch Raylib - download and build Raylib
#---------------------------------------------------------------
# TODO: fetch Emscripten and compile Raylib with Emscripten with no deps??
if(USE_RAYLIB_FETCH)
    if(IS_WEB)
        message(FATAL_ERROR "WORK IN PROGRESS ERROR: Use a local Web build of Raylib and USE_RAYLIB_LOCAL set to ON, to build for Web")
    endif()

    if(IS_DESKTOP)
        Fetch(raylib "https://github.com/raysan5/raylib.git" head)

        list(APPEND LIBRARIES raylib)
    endif()
endif()

# Local Raylib - Use a local build of Raylib
#---------------------------------------------------------------
# Path validations
if(USE_RAYLIB_LOCAL)
    # Raylib path - used for both desktop and web
    if(EXISTS "${LOCAL_RAYLIB}")
        message(STATUS "Using local Raylib: ${LOCAL_RAYLIB}")
    else()
        message(FATAL_ERROR "SETTINGS ERROR: Local Raylib path: ${LOCAL_RAYLIB} does not exist!")
    endif()

    # Raylib Web build path
    if(IS_WEB AND NOT EXISTS "${LOCAL_RAYLIB_WEB}")
        message(FATAL_ERROR "SETTINGS ERROR: Local Raylib Web path: ${LOCAL_RAYLIB_WEB} does not exist!")
    endif()

    # Emscripten include folder path
    if(IS_WEB AND NOT EXISTS "${LOCAL_EM_INCLUDE}")
        message(FATAL_ERROR "SETTINGS ERROR: Emscripten include path: ${LOCAL_EM_INCLUDE} does not exist!")
    endif()
endif()

# Local Raylib Desktop Setup
if(USE_RAYLIB_LOCAL AND IS_DESKTOP)
    find_library(PATH_RAYLIB raylib PATHS "${LOCAL_RAYLIB}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)

    add_library(raylib STATIC IMPORTED)
    set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${PATH_RAYLIB}")

    target_include_directories(${PROJECT_NAME} PRIVATE "${LOCAL_RAYLIB}")

    list(APPEND LIBRARIES raylib)

    if(OS STREQUAL Windows)
        list(APPEND LIBRARIES winmm)
    endif()
endif()

# Local Raylib Web Setup
if(USE_RAYLIB_LOCAL AND IS_WEB)
    message(STATUS "Using local Raylib Web: ${LOCAL_RAYLIB_WEB}")

    find_library(PATH_RAYLIB_WEB raylib PATHS "${LOCAL_RAYLIB_WEB}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)

    add_library(raylib STATIC IMPORTED)
    set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${PATH_RAYLIB_WEB}")
    set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".html")

    target_include_directories(${PROJECT_NAME} PRIVATE "${LOCAL_RAYLIB}" PRIVATE "${LOCAL_EM_INCLUDE}")

    # FULL_ES3 requires Raylib to be compiled for Web with OpenGL ES3 (see README requirements)
    target_link_options(${PROJECT_NAME} PRIVATE 
        -sFULL_ES3 
        -sUSE_GLFW=3 
        -sASYNCIFY
        -sWASM=1
        -sEXPORT_ES6=1
        -sGL_ENABLE_GET_PROC_ADDRESS=1
        -sTOTAL_MEMORY=67108864 
        -sFORCE_FILESYSTEM=1
        -sEXPORTED_RUNTIME_METHODS=ccall,cwrap,HEAPF32 
        --preload-file "../${DIR_ASSETS}" 
        --shell-file "${LOCAL_RAYLIB}/shell.html" 
        # --emrun 
    )

    list(APPEND LIBRARIES raylib)
endif()

#                      LINK LIBRARIES
#═══════════════════════════════════════════════════════════════

target_link_libraries(${LIBRARIES})

#                      BUILD REFLECTION
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
# Set install folder
if(IS_WEB)
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${DIR_INSTALL}-web")
else()
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${DIR_INSTALL}")
endif()

# Install files
install(TARGETS ${PROJECT_NAME} DESTINATION "${PATH_BUILD}")
