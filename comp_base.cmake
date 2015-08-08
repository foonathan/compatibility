# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# comp_base.cmake - base functionality for all compatibility files

include(CheckCXXSourceCompiles)
include(CheckCXXCompilerFlag)
include(CMakeParseArguments)

macro(_comp_setup_feature path feature)
    if(NOT EXISTS "${comp_path}/${feature}.cmake")
        file(DOWNLOAD https://raw.githubusercontent.com/foonathan/compatibility/master/${feature}.cmake
                     ${path}/${feature}.cmake
                     SHOW_PROGESS
                     STATUS status
                     LOG log)
        list(GET status 0 status_code)
        list(GET status 1 status_string)
        if(NOT status_code EQUAL 0)
            message(FATAL_ERROR "error downloading feature file ${feature}.cmake: ${status_string} - ${log}")
        endif()
    endif()
    include("${path}/${feature}.cmake")
endmacro()

# setups certain features for a target
macro(comp_target_features target include_policy)
    cmake_parse_arguments(COMP "NOPREFIX;CPP11;CPP14" "PREFIX;NAMESPACE;CMAKE_PATH;INCLUDE_PATH" "" ${ARGN})
    if(COMP_NOPREFIX)
        set(COMP_PREFIX "")
    elseif(NOT DEFINED COMP_PREFIX)
        set(COMP_PREFIX "COMP_")
    endif()
    if(NOT DEFINED COMP_NAMESPACE)
        set(COMP_NAMESPACE "comp")
    endif()
    if(NOT DEFINED COMP_CMAKE_PATH)
        set(COMP_CMAKE_PATH "${CMAKE_CURRENT_BINARY_DIR}")
    endif()
    if(NOT DEFINED COMP_INCLUDE_PATH)
        set(COMP_INCLUDE_PATH "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    set(_comp_need_cpp11 FALSE)
    set(_comp_need_cpp14 FALSE)

    target_include_directories(${target} ${include_policy} ${COMP_INCLUDE_PATH})
    foreach(feature ${COMP_UNPARSED_ARGUMENTS})
        _comp_setup_feature(${COMP_CMAKE_PATH} ${feature})
    endforeach()

    # first explicit option, then implicit; 14 over 11
    if(COMP_CPP14)
        target_compile_options(${target} PRIVATE ${cpp14_flag})
    elseif(COMP_CPP11)
        target_compile_options(${target} PRIVATE ${cpp11_flag})
    elseif(_comp_need_cpp14)
        target_compile_options(${target} PRIVATE ${cpp14_flag})
    elseif(_comp_need_cpp11)
        target_compile_options(${target} PRIVATE ${cpp11_flag})
    endif()
endmacro()

# possible C++11 flags
check_cxx_compiler_flag("-std=c++11" has_cpp11_flag) # newer GCC/Clang
check_cxx_compiler_flag("-std=c++0x" has_cpp0x_flag) # older GCC/Clang

if(has_cpp11_flag)
    set(cpp11_flag "-std=c++11")
elseif(has_cpp0x_flag)
    set(cpp11_flag "-std=c++0x")
else()
    message(WARNING "No required C++11 flag found, this could either be the case or missing support for your compiler.")
    set(cpp11_flag "")
endif()

# possible C++14 flags
check_cxx_compiler_flag("-std=c++14" has_cpp14_flag) # newer GCC/Clang
check_cxx_compiler_flag("-std=c++1y" has_cpp1y_flag) # older GCC/Clang

if(has_cpp14_flag)
    set(cpp14_flag "-std=c++14")
elseif(has_cpp1y_flag)
    set(cpp14_flag "-std=c++1y")
else()
    message(WARNING "No required C++14 flag found, this could either be the case or missing support for your compiler.")
    set(cpp14_flag "")
endif()

# checks if ${code}, which is a feature test code, compiles
# provides option COMP_HAS_${name} defaulted to result
# flags specify the required compiler flags for the test
# and can be obtained via cpp11/14_flags
macro(comp_check_feature code name flags)
    string(FIND "${flags}" "${cpp14_flag}" res)
    if(NOT (res EQUAL -1))
        set(_comp_need_cpp14 TRUE)
    else()
        string(FIND "${flags}" "${cpp11_flag}" res)
        if(NOT (res EQUAL -1))
            set(_comp_need_cpp11 TRUE)
        endif()
    endif()

    set(CMAKE_REQUIRED_FLAGS "${flags}")
    check_cxx_source_compiles("${code}" has_${name})

    string(TOUPPER "${name}" macro_name)
    if(has_${name})
        option(COMP_HAS_${macro_name} "whether or not ${name} is available" ON)
    else()
        option(COMP_HAS_${macro_name} "whether or not ${name} is available" OFF)
    endif()
endmacro()

# writes test result into a new header file ${CMAKE_CURRENT_BINARY_DIR}/comp/${name}.hpp
# also write workaround code
# test result is available via macor ${COMP_PREFIX}HAS_${name in uppercase}
macro(comp_gen_header name workaround)
    string(TOUPPER "${name}" macro_name)
    if (COMP_HAS_${macro_name})
        set(result "1")
    else()
        set(result "0")
    endif()

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/comp/${name}.hpp
"#ifndef COMP_IN_PARENT_HEADER
#error \"Don't include this file directly, only into a proper parent header.\"
#endif

#define ${COMP_PREFIX}HAS_${macro_name} ${result}
${workaround}")
endmacro()
