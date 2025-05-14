cmake_minimum_required(VERSION 3.18)

set(PROJECT_NAME "Example")
set(PROJECT_VERSION "1.0.0")
set(DEFAULT_DEBUG ON)
# Project directories relative to root
set(PROJECT_SOURCE "source")
set(PROJECT_INCLUDE "include")
set(PROJECT_RESOURCE "resource")
set(PROJECT_CONFIG "config")
set(PROJECT_BUILD "bin")
set(PROJECT_BUILD_WEB "web")
# Dependencies
set(LIB_RAYLIB_PATH "C:/raylib/raylib/src")
set(LIB_RAYLIB_WEB_PATH "C:/raylib/raylib/src/web")

# Define project
project("${PROJECT_NAME}" VERSION 1.0.0 DESCRIPTION "${PROJECT_NAME}" LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
# Define source and include files and directories
file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_SOURCE}/*.cpp")
set(PROJECT_INCLUDES "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_INCLUDE}")

# Project
add_executable(${PROJECT_NAME})
target_sources(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCES})
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_INCLUDES})
set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_DEFINITIONS DEBUG_MODE=${DEFAULT_DEBUG} COMPILE_DEFINITIONS PLATFORM=WINDOWS)

if(PLATFORM STREQUAL WEB)
    message(STATUS "Configuring Raylib for Web")
    find_library(RAYLIB raylib PATHS "${LIB_RAYLIB_WEB_PATH}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)
    message(STATUS "Using Raylib: ${RAYLIB}")
    add_library(raylib STATIC IMPORTED)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -DPLATFORM_WEB -std=c++17 -Os -Wall -Wno-missing-braces -Wunused-result -s USE_GLFW=3 -s ASSERTIONS=1 -s ASYNCIFY -s WASM=1 -s TOTAL_MEMORY=67108864 -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=ccall,cwrap,HEAPF32 --preload-file ../${PROJECT_RESOURCE} --shell-file ${LIB_RAYLIB_PATH}/shell.html --emrun")
    # set_property(TARGET ${PROJECT_NAME} PROPERTY -s EXTRA_EXPORTED_RUNTIME_METHODS=['ccall', 'cwrap', 'HEAPF32'])
    # set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "-DPLATFORM_WEB -std=c++17 -Os -Wall -Wno-missing-braces -Wunused-result -s USE_GLFW=3 -s ASSERTIONS=1 -s ASYNCIFY -s WASM=1 -s TOTAL_MEMORY=67108864 -s FORCE_FILESYSTEM=1 --preload-file ${PROJECT_RESOURCE} --shell-file ${LIB_RAYLIB_PATH}/minshell.html --emrun")
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    # set(LINK_OPTIONS ${LINK_OPTIONS} -o output.html -DPLATFORM_WEB -std=c++17 -Os -Wall -Wno-missing-braces -Wunused-result -s USE_GLFW=3 -s ASSERTIONS=1 -s ASYNCIFY -s WASM=1 -s TOTAL_MEMORY=67108864 -s FORCE_FILESYSTEM=1 --preload-file ${PROJECT_RESOURCE} --shell-file ${LIB_RAYLIB_PATH}/minshell.html --emrun)
    # set(LINK_LIBRARIES ${LINK_LIBRARIES} -lglfw3)
    target_include_directories(${PROJECT_NAME} PRIVATE ${LIB_RAYLIB_PATH})
    set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${RAYLIB}")
    target_link_libraries(${PROJECT_NAME} raylib)
else()
    message(STATUS "Configuring Raylib")
    find_library(RAYLIB raylib PATHS "${LIB_RAYLIB_PATH}" REQUIRED NO_CMAKE_FIND_ROOT_PATH)
    message(STATUS "Using Raylib: ${RAYLIB}")
    add_library(raylib STATIC IMPORTED)
    set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${RAYLIB}")
    target_link_libraries(${PROJECT_NAME} raylib winmm)
endif()


# Get current date
execute_process(COMMAND date "+%Y-%m-%d %H:%M:%S" OUTPUT_VARIABLE OUTPUT_DATE)
string(STRIP "${OUTPUT_DATE}" BUILD_DATE)

# Debug placeholder
if(DEBUG_MODE)
    message(STATUS "Debug mode is ON")
endif()

# Configure file
set(PATH_CONFIG "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_INCLUDE}/${PROJECT_CONFIG}")
configure_file("${PATH_CONFIG}.h.in" "${PATH_CONFIG}.h")

# Create build folder
if(PLATFORM STREQUAL WEB)
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_BUILD_WEB}")
else()
    set(PATH_BUILD "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_BUILD}")
endif()

if(NOT EXISTS "${PATH_BUILD}")
    file(MAKE_DIRECTORY "${PATH_BUILD}")
endif()

install(TARGETS ${PROJECT_NAME} DESTINATION "${PATH_BUILD}")
