# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# comp_base.cmake - base functionality for all compatibility files
if(${CMAKE_MINIMUM_REQUIRED_VERSION} VERSION_LESS 3.0)
    message(FATAL_ERROR "compat requires CMake version 3.0+")
endif()

include(CheckCXXSourceCompiles)
include(CheckCXXCompilerFlag)
include(CMakeParseArguments)

# EXTERNAL
# the current API version
set(COMP_API_VERSION 1.1 CACHE INTERNAL "compatibility api version" FORCE)

set(COMP_REMOTE_REPO "foonathan/compatibility" CACHE STRING "Github Repository to pull from")
set(COMP_REMOTE_BRANCH "master" CACHE STRING "Git branch on COMP_REMOTE_REPO")

# EXTERNAL
# download location for feature files, the feature file name will be appended
# to circumvent download process, manually place the files at the CMAKE_PATH
set(COMP_REMOTE_URL "https://raw.githubusercontent.com/${COMP_REMOTE_REPO}/${COMP_REMOTE_BRANCH}/" CACHE STRING "url of remote repository to be used for downloading the feature files")

set(_COMP_LOG_LVL_DEBUG     3       CACHE INTERNAL "Logging Level: Debug")
set(_COMP_LOG_LVL_INFO      2       CACHE INTERNAL "Logging Level: Info")
set(_COMP_LOG_LVL_QUIET     1       CACHE INTERNAL "Logging Level: Quiet")
set(_COMP_LOG_LVL_SILENT    0       CACHE INTERNAL "Logging Level: Silent")
set(_COMP_LOG_LVL_ALL       100     CACHE INTERNAL "Logging Level: ALL")

set(COMP_LOG_LEVEL "INFO" CACHE STRING "Default logging level used within all calls (default: INFO)")

macro(_comp_adjust_log_level VARIABLE LEVEL)
    if(${LEVEL} MATCHES "(0|1|2|3|100)")
        set(${VARIABLE} ${LEVEL})
    elseif(${LEVEL} MATCHES "(DEBUG|INFO|QUIET|SILENT|ALL)")
        set(${VARIABLE} ${_COMP_LOG_LVL_${VARIABLE}})
    else()
        message(WARNING "Tried to set ${VARIABLE} to ${LEVEL}, defaulting to INFO.")
        comp_set_log_level(${VARIABLE} INFO)
    endif()
endmacro()

# External; Sets the `COMP_LOG_LEVEL` variable using either the `_COMP_LOG_LVL_XX`
# variables or string versions.
function(comp_set_log_level LEVEL)
    _comp_adjust_log_level(log_level ${LEVEL})
    set(COMP_LOG_LEVEL ${log_level} CACHE STRING "Default logging level used within all calls (default: INFO)")
endfunction()

if(NOT COMP_LOG_LEVEL)
    comp_set_log_level(INFO)
else()
    comp_set_log_level(${COMP_LOG_LEVEL})
endif()

# Internal;
# Log a message based on the current log level
function(_comp_log level out_message)
    cmake_parse_arguments(log "EXACT" "" "" ${ARGN})

    set(log off)
    if(NOT DEFINED COMP_LOG_LVL OR (${level} STREQUAL "ALL" OR COMP_LOG_LVL EQUAL ${_COMP_LOG_LVL_ALL}))
        set(log on)
    elseif(LOG_EXACT )
        if(COMP_LOG_LVL EQUAL ${_COMP_LOG_LVL_${level}})
            set(log on)
        endif()
    elseif(COMP_LOG_LVL GREATER ${_COMP_LOG_LVL_${level}}
            OR COMP_LOG_LVL EQUAL ${_COMP_LOG_LVL_${level}})
        set(log on)
    endif()

    if(log)
        message(STATUS ${out_message})
    endif()
endfunction()

# EXTERNAL; feature module
# requires a certain API version
function(comp_api_version version)
    string(FIND "${version}" "." first_dot)
    string(SUBSTRING "${version}" 0 ${first_dot} major_version)
    string(FIND "${COMP_API_VERSION}" "." first_dot)
    string(SUBSTRING "${COMP_API_VERSION}" 0 ${first_dot} comp_major_version)

    if(NOT major_version EQUAL comp_major_version OR COMP_API_VERSION VERSION_LESS version)
        message(FATAL_ERROR "compatibility version is ${COMP_API_VERSION}, required is ${version}")
    endif()
endfunction()

# INTERNAL
# gets name, followed by flag, name, flag, name, flag...
# checks flags in order of occurence
# first matching flag will be used!
# result is written into named cache option
function(_comp_check_flags result standard_name)
    if(DEFINED ${result})
        # If its defined, it likely means the library was included multiple times and we already
        # searched for it.
        return()
    endif()

    _comp_log(INFO "Checking flags for ${standard_name}")
    foreach(flag ${ARGN})
        if(NOT DEFINED name)
            set(name ${flag})
        else()
            set(CMAKE_REQUIRED_QUIET ON)
            check_cxx_compiler_flag("${flag}" ${name})
            if(${name})
                _comp_log(ALWAYS "Checking flags for ${standard_name} - Found: ${flag}")
                set(${result} ${flag} CACHE INTERNAL "Flag to activate ${standard_name}")
                return()
            elseif(MSVC)
                # MSVC < 2016 does *not* support the -std flag.
                if(NOT _COMP_MSVC_FLAG_${standard_name}_MSG_SHOWN)
                    set(_COMP_MSVC_FLAG_${standard_name}_MSG_SHOWN TRUE CACHE INTERNAL '')
                    _comp_log(INFO "Tried to check for ${standard_name}, but MSVC does not support flags.")
                endif()
                set(${result} "" CACHE INTERNAL "Flag to activate ${standard_name} (MSVC defaulted to ON)")
                return()
            endif()
            unset(name)
        endif()
    endforeach()
    message(WARNING "Checking flags for ${standard_name} - No required ${standard_name} flag found,\
                    this could either be the case or missing support for your compiler.")
    set(${result} "" CACHE INTERNAL "Flag to activate ${standard_name}")
endfunction()

set(COMP_CPP98_FLAG "" CACHE INTERNAL "Flag to activate C++98")
_comp_check_flags(COMP_CPP11_FLAG "C++11" std_cpp11_flag -std=c++11 std_cpp0x_flag -std=c++0x)
_comp_check_flags(COMP_CPP14_FLAG "C++14" std_cpp14_flag -std=c++14 std_cpp1y_flag -std=c++1y)
_comp_check_flags(COMP_CPP17_FLAG "C++17" std_cpp17_flag -std=c++17 std_cpp1z_flag -std=c++1z)

# INTERNAL
# parses arguments for comp_compile_features
macro(_comp_parse_arguments)
    cmake_parse_arguments(COMP "NOPREFIX;NO_HEADER_MACROS;CPP11;CPP14;CPP17;NOFLAGS" # no arg
                               "PREFIX;NAMESPACE;CMAKE_PATH;INCLUDE_PATH;LOG;SINGLE_HEADER" # single arg
                                "" ${ARGN})
    if(COMP_NOPREFIX)
        set(COMP_PREFIX "")
        set(COMP_ID "")
    elseif(NOT DEFINED COMP_PREFIX)
        set(COMP_PREFIX "COMP_")
        set(COMP_ID "comp")
    elseif(${COMP_PREFIX} MATCHES "^.*_$")
        string(TOLOWER "${COMP_PREFIX}" COMP_ID)
        string(LENGTH "${COMP_ID}" length)
        math(EXPR length "${length} - 1")
        string(SUBSTRING "${COMP_ID}" 0 ${length} COMP_ID)
    else()
        string(TOLOWER "${COMP_PREFIX}" COMP_ID)
    endif()

    if(COMP_LOG)
        _comp_adjust_log_level(COMP_LOG ${COMP_LOG})
        set(COMP_LOG_LVL ${COMP_LOG})
    endif()

    if(NOT DEFINED COMP_LOG_LVL)
        set(COMP_LOG_LVL ${COMP_LOG_LEVEL})
    endif()

    if(NOT DEFINED COMP_NAMESPACE)
        set(COMP_NAMESPACE "comp")
    endif()
    if(DEFINED _COMP_${COMP_ID}_namespace)
        if (NOT "${_COMP_${COMP_ID}_namespace}" STREQUAL "${COMP_NAMESPACE}")
            message(SEND_ERROR "Prefix ${COMP_PREFIX} already used with namespace name ${COMP_NAMESPACE} before")
        endif()
    else()
        set(_COMP_${COMP_ID}_namespace "${COMP_NAMESPACE}" CACHE INTERNAL "")
    endif()

    if(NOT DEFINED COMP_CMAKE_PATH)
        set(COMP_CMAKE_PATH "${CMAKE_BINARY_DIR}/comp.downloaded")
    endif()

    if(NOT DEFINED COMP_INCLUDE_PATH)
        set(COMP_INCLUDE_PATH "${CMAKE_BINARY_DIR}/comp.generated")
    endif()

    if(NOT DEFINED COMP_SINGLE_HEADER)
        set(COMP_SINGLE_HEADER off)
    endif()

    if(NOT DEFINED COMP_NO_HEADER_MACROS)
        set(COMP_NO_HEADER_MACROS off)
    endif()
endmacro()

# INTERNAL
# translates feature names
function(_comp_translate_feature feature)
    # Use a function so these don't bleed out of scope
    set(_cxx_alias_templates cpp11_lang/alias_template CACHE INTERNAL "")
    set(_cxx_alignas cpp11_lang/alignas CACHE INTERNAL "")
    set(_cxx_alignof cpp11_lang/alignof CACHE INTERNAL "")
    set(_cxx_attribute_deprecated cpp14_lang/deprecated CACHE INTERNAL "")
    set(_cxx_auto_type cpp11_lang/auto_type CACHE INTERNAL "")
    set(_cxx_constexpr cpp11_lang/constexpr CACHE INTERNAL "")
    set(_cxx_decltype cpp11_lang/decltype CACHE INTERNAL "")
    set(_cxx_decltype_auto cpp14_lang/return_type_deduction CACHE INTERNAL "")
    set(_cxx_deleted_functions cpp11_lang/delete_fnc CACHE INTERNAL "")
    set(_cxx_default_function_template_args cpp11_lang/default_function_template_args CACHE INTERNAL "")
    set(_cxx_explicit_conversions cpp11_lang/explicit_conversion_op CACHE INTERNAL "")
    set(_cxx_final cpp11_lang/final CACHE INTERNAL "")
    set(_cxx_lambdas cpp11_lang/lambdas CACHE INTERNAL "")
    set(_cxx_noexcept cpp11_lang/noexcept CACHE INTERNAL "")
    set(_cxx_nullptr cpp11_lang/nullptr CACHE INTERNAL "")
    set(_cxx_override cpp11_lang/override CACHE INTERNAL "")
    set(_cxx_relaxed_constexpr cpp14_lang/general_constexpr CACHE INTERNAL "")
    set(_cxx_range_for cpp11_lang/range_for CACHE INTERNAL "")
    set(_cxx_return_type_deduction cpp14_lang/return_type_deduction CACHE INTERNAL "")
    set(_cxx_right_angle_brackets cpp11_lang/right_angle_brackets CACHE INTERNAL "")
    set(_cxx_rvalue_references cpp11_lang/rvalue_ref CACHE INTERNAL "")
    set(_cxx_static_assert cpp11_lang/static_assert CACHE INTERNAL "")
    set(_cxx_strong_enums cpp11_lang/enum_class CACHE INTERNAL "")
    set(_cxx_thread_local cpp11_lang/thread_local CACHE INTERNAL "")
    set(_cxx_user_literals cpp11_lang/literal_op CACHE INTERNAL "")
    set(_cxx_variable_templates cpp14_lang/variable_template CACHE INTERNAL "")
    set(_cxx_variadic_templates cpp11_lang/parameter_pack CACHE INTERNAL "")

    # note: triple underscore at beginning!
    set(___cpp_alias_templates cpp11_lang/alias_template CACHE INTERNAL "")
    set(___cpp_constexpr cpp11_lang/constexpr CACHE INTERNAL "")
    set(___cpp_decltype cpp11_lang/decltype CACHE INTERNAL "")
    set(___cpp_user_defined_literals cpp11_lang/literal_op CACHE INTERNAL "")
    set(___cpp_noexcept cpp11_lang/noexcept CACHE INTERNAL "")
    set(___cpp_rvalue_references cpp11_lang/rvalue_ref CACHE INTERNAL "")
    set(___cpp_static_assert cpp11_lang/static_assert CACHE INTERNAL "")

    set(___cpp_return_type_deduction cpp14_lang/return_type_deduction CACHE INTERNAL "")
    set(___cpp_sized_deallocation cpp14_lang/sized_deallocation CACHE INTERNAL "")
    set(___cpp_variable_templates cpp14_lang/variable_template CACHE INTERNAL "")

    set(___cpp_lib_exchange_function cpp14_lib/exchange CACHE INTERNAL "")
    set(___cpp_lib_transparent_operators cpp14_lib/generic_operator_functors CACHE INTERNAL "")
    set(___cpp_lib_integer_sequence cpp14_lib/integer_sequence CACHE INTERNAL "")
    set(___cpp_lib_make_unique cpp14_lib/make_unique CACHE INTERNAL "")
    set(___cpp_lib_quoted_string_io cpp14_lib/quoted CACHE INTERNAL "")
    set(___cpp_lib_shared_timed_mutex cpp14_lib/shared_lock CACHE INTERNAL "")
    set(___cpp_lib_robust_nonmodifying_seq_ops cpp14_lib/two_range_algorithms CACHE INTERNAL "")

    set(___cpp_fold_expressions cpp17_lang/fold_expressions CACHE INTERNAL "")
    set(___cpp_unicode_characters cpp17_lang/utf8_char_literal CACHE INTERNAL "")

    set(___cpp_lib_nonmember_container_access cpp17_lib/container_access CACHE INTERNAL "")
    set(___cpp_lib_invoke cpp17_lib/invoke CACHE INTERNAL "")
    set(___cpp_lib_map_insertion cpp17_lib/map_insertion CACHE INTERNAL "")
    set(___cpp_lib_unordered_map_insertion cpp17_lib/map_insertion CACHE INTERNAL "")
    set(___cpp_lib_map_try_emplace cpp17_lib/map_insertion CACHE INTERNAL "")
    set(___cpp_lib_unordered_map_try_emplace cpp17_lib/map_insertion CACHE INTERNAL "")
    set(___cpp_lib_uncaught_exceptions cpp17_lib/uncaught_exceptions CACHE INTERNAL "")
    set(___cpp_lib_void_t cpp17_lib/void_t CACHE INTERNAL "")

    if(DEFINED _${feature})
        set(feature "${_${feature}}" PARENT_SCOPE)
    elseif(${feature} MATCHES "cxx_*")
        message(WARNING "no compatibility option for CMake feature ${feature}")
    elseif(${feature} MATCHES "__cpp_*")
        message(WARNING "no compatibility option for SD-6 feature ${feature}")
    endif()
endfunction()

# INTERNAL
# downloads the file for a feature
function(_comp_fetch_feature path feature)
    if(NOT EXISTS "${path}/${feature}.cmake")
        if(${COMP_LOG_LVL} GREATER ${_COMP_LOG_LVL_INFO})
            set(show_progress_flag "SHOW_PROGRESS")
        else()
            set(show_progress_flag "")
        endif()

        file(DOWNLOAD ${COMP_REMOTE_URL}${feature}.cmake
                     ${path}/${feature}.cmake
                     ${show_progress_flag}
                     STATUS status
                     LOG log)
        list(GET status 0 status_code)
        list(GET status 1 status_string)
        if(NOT status_code EQUAL 0)
            message(FATAL_ERROR "error downloading feature file ${feature}.cmake: ${status_string}. Check spelling of feature.\n${log}")
        endif()
    endif()
endfunction()

# INTERNAL
# writes the header and testing code, if needed
function(_comp_gen_files feature)
    get_filename_component(name "${feature}" NAME_WE)
    string(TOUPPER "${name}" macro_name)

    if (COMP_HAS_${macro_name})
        set(result "1")
    else()
        set(result "0")
    endif()

    list(APPEND _COMP_HEADERS ${COMP_PREFIX}${macro_name}_HEADER="${COMP_INCLUDE_PATH}/${COMP_ID}/${name}.hpp")
    set(_COMP_HEADERS "${_COMP_HEADERS}" PARENT_SCOPE)

    file(WRITE ${COMP_INCLUDE_PATH}/${COMP_ID}/${name}.hpp
"// This file was autogenerated using foonathan/compatibility.
// See https://github.com/foonathan/compatibility for further information.
// Do not edit manually!

#ifndef COMP_${COMP_PREFIX}${macro_name}_HPP_INCLUDED
#define COMP_${COMP_PREFIX}${macro_name}_HPP_INCLUDED

#include <cstddef>

#define ${COMP_PREFIX}HAS_${macro_name} ${result}

${${name}_sd6_macro}
${${name}_requires}
${${name}_workaround}

#endif
")
    if(${name}_test_code)
        file(WRITE ${_COMP_TEST}/${name}.cpp
                "#define COMP_IN_PARENT_HEADER
                #include <cstddef>
                #include <comp/${name}.hpp>

                #include \"catch.hpp\"

                ${${name}_test_global}

                TEST_CASE(\"${name}\", \"\")
                {
                    ${${name}_test_code}
                }")
    endif()
endfunction()

# INTERNAL
# handles a feature file
function(_comp_handle_feature feature)
    _comp_translate_feature(${feature})
    _comp_fetch_feature(${COMP_CMAKE_PATH} ${feature})
    include(${COMP_CMAKE_PATH}/${feature}.cmake)
    _comp_gen_files(${feature})

    # propagate variables up
    set(_COMP_HEADERS "${_COMP_HEADERS}" PARENT_SCOPE)
endfunction()

# EXTERNAL; user
# setups certain features for a target
function(comp_target_features target include_policy)
    _comp_parse_arguments(${ARGN})

    # these variables are modified/accessed by the feature modules
    # deprecated
    set(cpp11_flag ${COMP_CPP11_FLAG})
    set(cpp14_flag ${COMP_CPP14_FLAG})
    set(cpp17_flag ${COMP_CPP17_FLAG})

    list(LENGTH COMP_UNPARSED_ARGUMENTS _args_len)
    _comp_log(QUIET "Checking ${_args_len} features" EXACT)
    foreach(feature ${COMP_UNPARSED_ARGUMENTS})
        _comp_handle_feature(${feature})
    endforeach()

    target_include_directories(${target} ${include_policy} $<BUILD_INTERFACE:${COMP_INCLUDE_PATH}>)

    if((NOT COMP_SINGLE_HEADER) AND (NOT COMP_NO_HEADER_MACROS))
        target_compile_definitions(${target} ${include_policy} ${_COMP_HEADERS})
    endif()

    # first explicit option, then implicit; 17 over 14 over 11
    if(COMP_CPP17)
        set(${target}_COMP_COMPILE_OPTIONS ${COMP_CPP17_FLAG}
           CACHE STRING "required compile options for target")
    elseif(COMP_CPP14)
        set(${target}_COMP_COMPILE_OPTIONS ${COMP_CPP14_FLAG}
           CACHE STRING "required compile options for target")
    elseif(COMP_CPP11)
        set(${target}_COMP_COMPILE_OPTIONS ${COMP_CPP14_FLAG}
           CACHE STRING "required compile options for target")
    elseif(need_COMP_CPP17_FLAG)
        set(${target}_COMP_COMPILE_OPTIONS ${COMP_CPP17_FLAG}
           CACHE STRING "required compile options for target")
    elseif(need_COMP_CPP14_FLAG)
        set(${target}_COMP_COMPILE_OPTIONS ${COMP_CPP14_FLAG}
           CACHE STRING "required compile options for target")
    elseif(need_COMP_CPP11_FLAG)
        set(${target}_COMP_COMPILE_OPTIONS ${COMP_CPP11_FLAG}
           CACHE STRING "required compile options for target")
    endif()

    # actually set option
    if (NOT COMP_NOFLAGS)
        target_compile_options(${target} PRIVATE ${${target}_COMP_COMPILE_OPTIONS})
    endif()

    if(COMP_SINGLE_HEADER)
        set(include_lines )
        foreach(header ${headers})
            string(REGEX REPLACE ".+=\"(.+)\"" "\\1" header_path ${header})
            file(RELATIVE_PATH header_path ${COMP_INCLUDE_PATH} ${header_path})
            list(APPEND include_lines "#include \"${header_path}\"\n")
        endforeach()

        string(REPLACE ";" "" include_lines "${include_lines}")

        file(WRITE ${COMP_INCLUDE_PATH}/${COMP_ID}/${COMP_SINGLE_HEADER}
        "// This file was autogenerated using foonathan/compatibility.
// See https://github.com/foonathan/compatibility for further information.
// Do not edit manually!

#ifndef COMP_${COMP_PREFIX}CONFIG_HPP_INCLUDED
#define COMP_${COMP_PREFIX}CONFIG_HPP_INCLUDED

${include_lines}

#endif")

    endif()

    list(LENGTH COMP_UNPARSED_ARGUMENTS _args_len)
    _comp_log(QUIET "Checking ${_args_len} features -- Completed" EXACT)
endfunction()

# EXTERNAL; feature module
# checks for a feature with ${name} by compiling ${test_code}
# standard is COMP_CPPXX_FLAG and will be used for testing
# additional arguments are required other features, if they are not supported, it will be neither
function(comp_feature name test_code standard)
    string(TOUPPER "${name}" macro_name)

    _comp_log(DEBUG "Checking for feature ${name}")

    if(_COMP_TEST_WORKAROUND)
        set(COMP_HAS_${macro_name} OFF CACHE INTERNAL "whether or not ${name} is available" FORCE)
    elseif(DEFINED COMP_HAS_${macro_name})

        _comp_log(INFO "Checking for feature ${name} - overriden")

        if(COMP_HAS_${macro_name})
            set(need_${standard} TRUE PARENT_SCOPE)
        endif()
    else()

        set(result ON)
        foreach(feature ${ARGN})
            _comp_handle_feature(${feature})
            get_filename_component(cur_name "${feature}" NAME_WE)
            string(TOUPPER "${cur_name}" cur_name)
            if(NOT COMP_HAS_${cur_name})
                set(result OFF)
                _comp_log(ALL "Checking for feature ${name} - Requirement failure: ${feature}")
            endif()
        endforeach()

        if(result)
            set(CMAKE_REQUIRED_FLAGS "${${standard}}")
            set(CMAKE_REQUIRED_QUIET ON)
            check_cxx_source_compiles("${test_code}" has_${name})

            if(has_${name})
                set(COMP_HAS_${macro_name} ON CACHE INTERNAL "whether or not ${name} is available")
                set(need_${standard} TRUE PARENT_SCOPE)
                _comp_log(INFO "Checking for feature ${name} - overriden")
            else()
                set(COMP_HAS_${macro_name} OFF CACHE INTERNAL "whether or not ${name} is available")
                _comp_log(ALL "Checking for feature ${name} - Failed")
            endif()
        else()
            set(COMP_HAS_${macro_name} OFF CACHE INTERNAL "whether or not ${name} is available")
        endif()
    endif()
endfunction()

# EXTERNAL; feature module
# writes workaround code
# test result is available via macro ${COMP_PREFIX}HAS_${name in uppercase}
# standard is COMP_CPPXX_FLAG required for the workaround code
# if the test succeds, the standard of the test is also activated
# additional arguments are required other features, their headers are also included then
function(comp_workaround name workaround standard)
    set(${name}_workaround "${workaround}" PARENT_SCOPE)
    set(need_${standard} TRUE PARENT_SCOPE)
    set(requires "")
    foreach(feature ${ARGN})
        get_filename_component(header "${feature}" NAME_WE)
        set(requires "${requires}#include \"${header}.hpp\"\n")
        _comp_handle_feature(${feature})
    endforeach()

    # Parent vars
    set(${name}_requires ${requires} PARENT_SCOPE)
    set(_COMP_HEADERS "${_COMP_HEADERS}" PARENT_SCOPE)
endfunction()

# EXTERNAL; feature module
# generates a unit test file for workaround of feature ${name}
# the include for the feature is available as is the Catch library
# ${code} will be placed inside a Catch TEST_CASE, ${global} in the global scope in front of it
function(comp_unit_test name global code)
    if (NOT _COMP_TEST)
        return()
    endif()

    set(${name}_test_code "${code}" PARENT_SCOPE)
    set(${name}_test_global "${global}" PARENT_SCOPE)
endfunction()

# EXTERNAL; feature module
# writes SD-6 feature macro with given name and value
# overrides existing value if given one is greater or macro COMP_OVERRIDE_SD6 is defined
function(comp_sd6_macro name sd6_name value)
    string(TOUPPER "${name}" macro_name)

    set(${name}_sd6_macro
"${${name}_sd6_macro}
#if ${COMP_PREFIX}HAS_${macro_name}
    #if !defined(${sd6_name})
        #define ${sd6_name} ${value}
    #elif ${value} > ${sd6_name}
        #undef ${sd6_name}
        #define ${sd6_name} ${value}
    #elif defined(COMP_OVERRIDE_SD6)
        #undef ${sd6_name}
        #define ${sd6_name} ${value}
    #endif
#endif" PARENT_SCOPE)
endfunction()

# EXTERNAL; umbrella feature module
# downloads and includes a feature named ${feature}
function(comp_fetch_include feature)
    _comp_fetch_feature(${COMP_CMAKE_PATH} ${feature})
    include(${COMP_CMAKE_PATH}/${feature}.cmake)
endfunction()

# DEPRECATED, use comp_workaround
macro(comp_gen_header name workaround)
    message(AUTHOR_WARNING "deprecated, use comp_workaround()")
    comp_workaround("${name}" "${workaround}" COMP_CPP98_FLAG)
endmacro()

# DEPRECATED, use comp_feature()
macro(comp_check_feature code name)
    message(AUTHOR_WARNING "deprecated, use comp_feature()")
    string(FIND "${ARGN}" "${cpp17_flag}" res)
    if (NOT (res EQUAL -1))
        comp_feature(${name} ${code} COMP_CPP17_FLAG)
    else()
        string(FIND "${ARGN}" "${cpp14_flag}" res)
        if(NOT (res EQUAL -1))
            comp_feature(${name} ${code} COMP_CPP14_FLAG)
        else()
            string(FIND "${ARGN}" "${cpp11_flag}" res)
            if(NOT (res EQUAL -1))
                comp_feature(${name} ${code} COMP_CPP11_FLAG)
            else()
                comp_feature(${name} ${code} COMP_CPP98_FLAG)
            endif()
        endif()
    endif()
endmacro()
