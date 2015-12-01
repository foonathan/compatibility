# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# comp_base.cmake - base functionality for all compatibility files

include(CheckCXXSourceCompiles)
include(CheckCXXCompilerFlag)
include(CMakeParseArguments)

# INTERNAL
# gets name, followed by flag, name, flag, name, flag...
# checks flags in order of occurence
# first matching flag will be used!
# result is written into named cache option
function(_comp_check_flags result standard_name)
    foreach(flag ${ARGN})
        if(NOT DEFINED name)
            set(name ${flag})
        else()
            check_cxx_compiler_flag("${flag}" ${name})
            if(${name})
                set(${result} ${flag} CACHE STRING "Flag to activate ${standard_name}")
                return()
            endif()
            unset(name)
        endif()
    endforeach()
    message(WARNING "No required ${standard_name} flag found,\
                    this could either be the case or missing support for your compiler.")
    set(${result} "" CACHE STRING "Flag to activate ${standard_name}")
endfunction()

_comp_check_flags(COMP_CPP11_FLAG "C++11" std_cpp11_flag -std=c++11 std_cpp0x_flag -std=c++0x)
_comp_check_flags(COMP_CPP14_FLAG "C++14" std_cpp14_flag -std=c++14 std_cpp1y_flag -std=c++1y)
_comp_check_flags(COMP_CPP17_FLAG "C++17" std_cpp17_flag -std=c++17 std_cpp1z_flag -std=c++1z)

# INTERNAL
# parses arguments for comp_compile_features
macro(_comp_parse_arguments)
    cmake_parse_arguments(COMP "NOPREFIX;CPP11;CPP14;CPP17;NOFLAGS" # no arg
                               "PREFIX;NAMESPACE;CMAKE_PATH;INCLUDE_PATH" # single arg
                                "" ${ARGN})
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
endmacro()

# INTERNAL
# translates feature names
function(_comp_translate_feature feature)
    set(_cxx_alias_templates cpp11_lang/alias_template)
    set(_cxx_alignas cpp11_lang/alignas)
    set(_cxx_alignof cpp11_lang/alignof)
    set(_cxx_attribute_deprecated cpp14_lang/deprecated)
    set(_cxx_constexpr cpp11_lang/constexpr)
    set(_cxx_decltype cpp11_lang/decltype)
    set(_cxx_deleted_functions cpp11_lang/delete_fnc)
    set(_cxx_explicit_conversions cpp11_lang/explicit_conversion_op)
    set(_cxx_final cpp11_lang/final)
    set(_cxx_noexcept cpp11_lang/noexcept)
    set(_cxx_nullptr cpp11_lang/nullptr)
    set(_cxx_override cpp11_lang/override)
    set(_cxx_relaxed_constexpr cpp14_lang/general_constexpr)
    set(_cxx_rvalue_references cpp11_lang/rvalue_ref)
    set(_cxx_static_assert cpp11_lang/static_assert)
    set(_cxx_thread_local cpp11_lang/thread_local)
    set(_cxx_user_literals cpp11_lang/literal_op)
    set(_cxx_variable_templates cpp14_lang/variable_template)

    if(DEFINED _${feature})
        set(feature "${_${feature}}" PARENT_SCOPE)
    elseif(${feature} MATCHES "cxx_*")
        message(WARNING "no compatibility option for CMake feature ${feature}")
    endif()
endfunction()

# INTERNAL
# downloads the file for a feature
function(_comp_fetch_feature path feature)
    if(NOT EXISTS "${path}/${feature}.cmake")
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
endfunction()

# EXTERNAL; user
# setups certain features for a target
function(comp_target_features target include_policy)
    _comp_parse_arguments(${ARGN})

    # these variables are modified/accessed by the feature modules
    set(need_cpp11 FALSE)
    set(need_cpp14 FALSE)
    set(need_cpp17 FALSE)
    set(cpp11_flag ${COMP_CPP11_FLAG})
    set(cpp14_flag ${COMP_CPP14_FLAG})
    set(cpp17_flag ${COMP_CPP17_FLAG})

    target_include_directories(${target} ${include_policy} ${COMP_INCLUDE_PATH})
    foreach(feature ${COMP_UNPARSED_ARGUMENTS})
        _comp_translate_feature(${feature})
        _comp_fetch_feature(${COMP_CMAKE_PATH} ${feature})
        include(${COMP_CMAKE_PATH}/${feature}.cmake)
    endforeach()

    if(COMP_NOFLAGS)
        return()
    endif()

    # first explicit option, then implicit; 17 over 14 over 11
    if(COMP_CPP17)
        target_compile_options(${target} PRIVATE ${cpp17_flag})
    elseif(COMP_CPP14)
        target_compile_options(${target} PRIVATE ${cpp14_flag})
    elseif(COMP_CPP11)
        target_compile_options(${target} PRIVATE ${cpp11_flag})
    elseif(need_cpp17)
        target_compile_options(${target} PRIVATE ${cpp17_flag})
    elseif(need_cpp14)
        target_compile_options(${target} PRIVATE ${cpp14_flag})
    elseif(need_cpp11)
        target_compile_options(${target} PRIVATE ${cpp11_flag})
    endif()
endfunction()

# EXTERNAL; feature module
# checks if ${code}, which is a feature test code, compiles
# provides option COMP_HAS_${name} defaulted to result
# flags specify the required compiler flags for the test
# and can be obtained via cpp11/14/17_flags
function(comp_check_feature code name)
    string(FIND "${ARGN}" "${cpp17_flag}" res)
    if (NOT (res EQUAL -1))
        set(need_cpp17 TRUE PARENT_SCOPE)
    else()
        string(FIND "${ARGN}" "${cpp14_flag}" res)
        if(NOT (res EQUAL -1))
            set(need_cpp14 TRUE PARENT_SCOPE)
        else()
            string(FIND "${ARGN}" "${cpp11_flag}" res)
            if(NOT (res EQUAL -1))
                set(need_cpp11 TRUE PARENT_SCOPE)
            endif()
        endif()
    endif()

    if(_COMP_TEST_WORKAROUND)
        string(TOUPPER "${name}" macro_name)
        set(COMP_HAS_${macro_name} OFF CACHE INTERNAL "" FORCE)
    else()
        set(CMAKE_REQUIRED_FLAGS "${ARGN}")
        check_cxx_source_compiles("${code}" has_${name})

        string(TOUPPER "${name}" macro_name)
        if(has_${name})
            option(COMP_HAS_${macro_name} "whether or not ${name} is available" ON)
        else()
            option(COMP_HAS_${macro_name} "whether or not ${name} is available" OFF)
        endif()
    endif()
endfunction()

# EXTERNAL; feature module
# writes test result into a new header file ${CMAKE_CURRENT_BINARY_DIR}/comp/${name}.hpp
# also write workaround code
# test result is available via macor ${COMP_PREFIX}HAS_${name in uppercase}
function(comp_gen_header name workaround)
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
endfunction()

# EXTERNAL; feature module
# generates a unit test file for workaround of feature ${name}
# the include for the feature is available as is the Catch library
# ${code} will be placed inside a Catch TEST_CASE, ${global} in the global scope in front of it
function(comp_unit_test name global code)
    if (NOT _COMP_TEST)
        return()
    endif()

    file (WRITE ${_COMP_TEST}/${name}.cpp
"
#define COMP_IN_PARENT_HEADER
#include <cstddef>
#include <comp/${name}.hpp>

#include <catch.hpp>

${global}

TEST_CASE(\"${name}\", \"\")
{
    ${code}
}
")
endfunction()
