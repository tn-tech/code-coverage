# Find required programs
find_program(LLVM_COV llvm-cov)
find_program(LLVM_PROFDATA llvm-profdata)
find_program(LCOV lcov)
find_program(GCOV gcov)
find_program(GCOVR gcovr)
find_program(GENHTML genhtml)

# Set needed variables
set(CMAKE_COVERAGE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/coverage)
if ("${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
    message(STATUS "LLVM/Clang family toolset detected.")
    if (LLVM_COV)
        message(STATUS "Found llvm-cov      -> ${LLVM_COV}")
    else ()
        message(FATAL_ERROR "llvm-cov program not found. Aborting.")
    endif ()
    if (LLVM_PROFDATA)
        message(STATUS "Found llvm-profdata -> ${LLVM_PROFDATA}")
    else ()
        message(FATAL_ERROR "llvm-profdata program not found. Aborting.")
    endif ()
    set(USING_CLANG ON)
    # Spaces at the end of the flags are important in case additional options need to be added by
    # other built in or 3rd party cmake modules that do not know that we exist.
    set(COVERAGE_COMPILER_FLAGS "-fprofile-instr-generate -fcoverage-mapping --coverage -ftest-coverage")
    set(COVERAGE_LINKER_FLAGS "-fprofile-instr-generate -fcoverage-mapping ")
elseif ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    message(STATUS "GNU family toolset detected.")
    if (LCOV)
        message(STATUS "Found lcov    -> ${LCOV}")
    else ()
        message(FATAL_ERROR "lcov program not found. Aborting.")
    endif ()
    if (GCOV)
        message(STATUS "Found gcov    -> ${GCOV}")
    else ()
        message(FATAL_ERROR "gcov program not found. Aborting.")
    endif ()
    if (GCOVR)
        message(STATUS "Found gcovr   -> ${GCOVR}")
    else ()
        message(FATAL_ERROR "gcovr program not found. Aborting.")
    endif ()
    if (GENHTML)
        message(STATUS "Found genhtml -> ${GENHTML}")
    else ()
        message(FATAL_ERROR "genhtml program not found. Aborting.")
    endif ()
    # Spaces at the end of the flags are important in case additional options need to be added by
    # other built in or 3rd party cmake modules that do not know that we exist.
    set(COVERAGE_COMPILER_FLAGS "--coverage -fprofile-arcs -ftest-coverage ")
    set(COVERAGE_LIBS "gcov")
    set(USING_GCC ON)
endif ()

separate_arguments(COVERAGE_COMPILER_FLAGS)
separate_arguments(COVERAGE_LINKER_FLAGS)

add_custom_target(coverage-preprocessing
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}
        DEPENDS coverage-clean)

function(enable_coverage TARGET)
    # Let's our coverage target if not already added. This target will execute unit tests and generate
    # code coverage support.
    if (NOT TARGET coverage)
        add_custom_target(coverage)
    endif ()
    if (USING_CLANG)
        enable_coverage_clang(${TARGET})
    elseif (USING_GCC)
        message(STATUS "Enabling code coverage for GNU toolchain.")
    elseif ()
        message(FATAL_ERROR "Code coverage support is only available for llvm and GNU toolsets.")
    endif ()
endfunction()

function(enable_coverage_clang TARGET)
    target_compile_options(${TARGET} PRIVATE ${COVERAGE_COMPILER_FLAGS})
    target_link_options(${TARGET} PRIVATE ${COVERAGE_LINKER_FLAGS})

    get_target_property(TARGET_TYPE ${TARGET} TYPE)
    if (NOT TARGET_TYPE STREQUAL "EXECUTABLE")
        message(STATUS "LLVM toolset code coverage for target ${TARGET} enabled.")
        return()
    endif ()

    if (NOT TARGET coverage-clean)
        add_custom_target(coverage-clean
                COMMAND rm -f ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/binaries.list
                COMMAND rm -f ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/profraw.list
                )
    endif ()

    add_custom_target(coverage-run-${TARGET}
            COMMAND LLVM_PROFILE_FILE=${TARGET}.profraw $<TARGET_FILE:${TARGET}>
            COMMAND echo "-object=$<TARGET_FILE:${TARGET}>" >> ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/binaries.list
            COMMAND echo "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.profraw " >> ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/profraw.list
            DEPENDS coverage-preprocessing ${TARGET}
            )

    add_custom_target(coverage-processing-${TARGET}
            COMMAND ${LLVM_PROFDATA} merge -sparse ${TARGET}.profraw -o ${TARGET}.profdata
            DEPENDS coverage-run-${TARGET})

    add_custom_target(coverage-show-${TARGET}
            COMMAND ${LLVM_COV} show $<TARGET_FILE:${TARGET}> -instr-profile=${TARGET}.profdata -show-line-counts-or-regions ${EXCLUDE_REGEX}
            DEPENDS coverage-processing-${TARGET}
            )

    add_custom_target(coverage-report-${TARGET}
            COMMAND ${LLVM_COV} report $<TARGET_FILE:${TARGET}> -instr-profile=${TARGET}.profdata ${EXCLUDE_REGEX}
            DEPENDS coverage-processing-${TARGET}
            )

    add_custom_target(coverage-${TARGET}
            COMMAND ${LLVM_COV} show $<TARGET_FILE:${TARGET}> -instr-profile=${TARGET}.profdata -show-line-counts-or-regions -output-dir=${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${TARGET} -format="html" ${EXCLUDE_REGEX}
            DEPENDS coverage-processing-${TARGET}
            )

    add_dependencies(coverage coverage-report-${TARGET})
    message(STATUS "LLVM toolset code coverage for target ${TARGET} enabled.")
endfunction()
