# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

cmake_minimum_required(VERSION 3.1)
project(COMPATIBILITY_TEST)

set(_COMP_TEST ${CMAKE_CURRENT_BINARY_DIR}/test)

# download catch
file(DOWNLOAD
        https://raw.githubusercontent.com/philsquared/Catch/master/single_include/catch.hpp
        ${_COMP_TEST}/catch.downloaded
        SHOW_PROGESS
        STATUS status
        LOG log)

list(GET status 0 status_code)
list(GET status 1 status_string)
if((NOT EXISTS  ${_COMP_TEST}/catch.hpp) AND (NOT status_code EQUAL 0))
    message(FATAL_ERROR "error downloading catch: ${status_string}"
            "${log}")
else()
    # succesful download, replace old catch.hpp
    file(RENAME ${_COMP_TEST}/catch.downloaded  ${_COMP_TEST}/catch.hpp)
endif()

include(../comp_base.cmake)

set(feature_names)
file(GLOB features ${CMAKE_CURRENT_SOURCE_DIR}/../*/*.cmake)
file(COPY main.cpp DESTINATION ${_COMP_TEST})
foreach(feature ${features})
    get_filename_component(header "${feature}" NAME_WE)
    string(TOUPPER "${header}" macro_name)
    get_filename_component(dir "${feature}" DIRECTORY)
    string(FIND "${dir}" "/" last_sep REVERSE)
    math(EXPR last_sep "${last_sep} + 1")
    string(SUBSTRING "${dir}" ${last_sep} -1 dir)

    file(APPEND ${_COMP_TEST}/main.cpp "#include COMP_${macro_name}_HEADER\n")
    list(APPEND feature_names "${dir}/${header}")
endforeach()

add_library(_comp_test_runner INTERFACE)
comp_target_features(_comp_test_runner INTERFACE ${feature_names}
                      CMAKE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../ NOFLAGS)

file(GLOB tests "${_COMP_TEST}/*.cpp")
add_executable(comp_test "${tests}")
comp_target_features(comp_test PRIVATE CPP17)
target_link_libraries(comp_test PUBLIC _comp_test_runner)
