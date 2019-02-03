cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
project(unit_testing)

# Set some variables that will define the build
option(CMAKE_ENABLE_CODE_COVERAGE "Controls whether we are building with code coverage or not." ON)

# We want C++17 without extensions
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Include code coverage support functions and macros if needed
if (${CMAKE_ENABLE_CODE_COVERAGE})
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
    include(Coverage)
endif ()

# Add conan support
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup(KEEP_RPATHS TARGETS)

# Add our library
add_subdirectory(lib)

# Add our unit tests
add_subdirectory(unittests)
