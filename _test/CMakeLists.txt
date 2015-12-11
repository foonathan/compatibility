# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

cmake_minimum_required(VERSION 3.1)
project(COMPATIBILITY_TEST)

# download catch
file(DOWNLOAD
        https://raw.githubusercontent.com/philsquared/Catch/master/single_include/catch.hpp
        ${CMAKE_CURRENT_BINARY_DIR}/catch.downloaded
        SHOW_PROGESS
        STATUS status
        LOG log)

list(GET status 0 status_code)
list(GET status 1 status_string)
if((NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/catch.hpp) AND (NOT status_code EQUAL 0))
    message(FATAL_ERROR "error downloading catch: ${status_string}"
            "${log}")
else()
    # succesful download, replace old catch.hpp
    file(RENAME ${CMAKE_CURRENT_BINARY_DIR}/catch.downloaded ${CMAKE_CURRENT_BINARY_DIR}/catch.hpp)
endif()

set(_COMP_TEST ${CMAKE_CURRENT_BINARY_DIR}/test)
include(../comp_base.cmake)

set(cpp11_flag ${COMP_CPP11_FLAG})
set(cpp14_flag ${COMP_CPP14_FLAG})
set(cpp17_flag ${COMP_CPP17_FLAG})
set(COMP_INCLUDE_PATH ${CMAKE_CURRENT_BINARY_DIR})

file(GLOB features ../*/*.cmake)
file(COPY main.cpp DESTINATION ${_COMP_TEST})
foreach(feature ${features})
    string(FIND ${feature} "/" last_sep REVERSE)
    string(SUBSTRING ${feature} ${last_sep} -1 header)
    string(REPLACE ".cmake" ".hpp" header ${header})
    file(APPEND ${_COMP_TEST}/main.cpp "#include <comp${header}>\n")
    include(${feature})
endforeach()

file(GLOB tests ${_COMP_TEST}/*.cpp)
add_executable(comp_test ${_COMP_TEST}/main.cpp ${tests})
target_include_directories(comp_test PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_compile_options(comp_test PRIVATE ${COMP_CPP17_FLAG})
