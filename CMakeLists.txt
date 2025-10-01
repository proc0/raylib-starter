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
# directories relative to root
set(DIR_ASSETS "assets")
set(DIR_INCLUDE "include")
set(DIR_INSTALL "bin")
set(DIR_INSTALL_WEB "web")
set(DIR_SOURCE "src")
set(FILE_CONFIG "config") #config file inside of include directory (optional)

# Raylib settings
option(USE_RAYLIB_FETCH "Use Raylib by fetching and building in project" OFF)
option(USE_RAYLIB_CUSTOM "Use custom Raylib modules" OFF)

# Local Raylib - provide local machine absolute paths
option(USE_RAYLIB_LOCAL "Use a local build of Raylib" ON)
set(LOCAL_RAYLIB "C:/raylib/raylib/src")
set(LOCAL_RAYLIB_WEB "C:/raylib/raylib/src/web")
set(LOCAL_EM_INCLUDE "C:/emsdk/upstream/emscripten/cache/sysroot/include/emscripten")

#                        REFLECTION
#═══════════════════════════════════════════════════════════════

# Internal flags
set(BUILD_DEBUG OFF)
set(BUILD_RELEASE OFF)
set(PLATFORM_DESKTOP OFF)
set(PLATFORM_WEB OFF)

if(BUILD_TYPE STREQUAL Debug)
    set(BUILD_DEBUG ON)
endif()

if(PLATFORM STREQUAL Desktop)
    set(PLATFORM_DESKTOP ON)
endif()

if(PLATFORM STREQUAL Web)
    set(PLATFORM_WEB ON)
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

# Compile definition
# target_compile_definitions(${PROJECT_NAME} PRIVATE DEBUG_BUILD=${BUILD_TYPE})
# target_compile_definitions(${PROJECT_NAME} PRIVATE PLATFORM=${OS})

#                           RAYLIB
#═══════════════════════════════════════════════════════════════

# Local static Raylib
if(USE_RAYLIB_LOCAL AND PLATFORM_DESKTOP)
    # message(STATUS "Configuring Raylib for Windows")
    find_library(PATH_RAYLIB raylib PATHS "${LOCAL_RAYLIB}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)
    message(STATUS "Using Raylib: ${PATH_RAYLIB}")

    add_library(raylib STATIC IMPORTED)
    set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${PATH_RAYLIB}")
    target_link_libraries(${PROJECT_NAME} raylib winmm)
endif()

# Local static Raylib Web
if(USE_RAYLIB_LOCAL AND PLATFORM_WEB)
    # message(STATUS "Configuring Raylib for Web")
    find_library(PATH_RAYLIB_WEB raylib PATHS "${LOCAL_RAYLIB_WEB}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)
    message(STATUS "Using Raylib: ${PATH_RAYLIB_WEB}")

    add_library(raylib STATIC IMPORTED)
    set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${PATH_RAYLIB_WEB}")
    target_link_libraries(${PROJECT_NAME} raylib)
    target_include_directories(${PROJECT_NAME} PRIVATE "${LOCAL_RAYLIB}" PRIVATE "${LOCAL_EM_INCLUDE}")

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
        --preload-file "../${DIR_ASSETS}" 
        --shell-file "${LOCAL_RAYLIB}/shell.html" 
        --emrun
    )
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
# Create build folder
if(PLATFORM_WEB)
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${DIR_INSTALL_WEB}")
endif()

if(PLATFORM_DESKTOP)
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${DIR_INSTALL}")
endif()

install(TARGETS ${PROJECT_NAME} DESTINATION "${PATH_BUILD}")
