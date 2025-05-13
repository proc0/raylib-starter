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
# Dependencies
set(RAYLIB_PATH "C:/raylib/raylib/src/")

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
set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_DEFINITIONS DEBUG_MODE=${DEFAULT_DEBUG})

# Raylib
find_library(RAYLIB raylib PATHS "${RAYLIB_PATH}" SEARCH_NAMES libraylib.a)
add_library(raylib STATIC IMPORTED)
set_target_properties(raylib PROPERTIES IMPORTED_LOCATION "${RAYLIB}")
target_link_libraries(${PROJECT_NAME} raylib winmm)

# Get current date
execute_process(COMMAND date "+%Y-%m-%d %H:%M:%S" OUTPUT_VARIABLE VAR_BUILD_DATE)
string(STRIP "${VAR_BUILD_DATE}" BUILD_DATE)

# Debug placeholder
if(DEBUG_MODE EQUAL 1)
    message(STATUS "Debug mode is ON")
endif()

# Configure file
configure_file("${PROJECT_INCLUDES}/${PROJECT_CONFIG}.h.in" "${PROJECT_INCLUDES}/${PROJECT_CONFIG}.h")

# Create build folder
if(NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_BUILD}")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_BUILD}")
endif()

install(TARGETS ${PROJECT_NAME} DESTINATION "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_BUILD}")
