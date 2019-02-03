cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
project(prop2json)

# Add our library
add_library(${PROJECT_NAME} SHARED Converter.cpp)

# Add include directories
target_link_libraries(${PROJECT_NAME} CONAN_PKG::boost)

if (CMAKE_ENABLE_CODE_COVERAGE)
    enable_coverage(${PROJECT_NAME})
endif ()