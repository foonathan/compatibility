# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# comp_base.cmake - base functionality for all compatibility files

if(TARGET comp_target)
    return()
endif()

include(CheckCXXSourceCompiles)
include(CheckCXXCompilerFlag)

# possible C++11 flags
CHECK_CXX_COMPILER_FLAG("-std=c++11" has_cpp11_flag) # newer GCC/Clang
CHECK_CXX_COMPILER_FLAG("-std=c++0x" has_cpp0x_flag) # older GCC/Clang

if(has_cpp11_flag)
    set(cpp11_flag "-std=c++11")
elseif(has_cpp0x_flag)
    set(cpp11_flag "-std=c++0x")
else()
    message(WARNING "No required C++11 flag found, this could either be the case or missing support for your compiler.")
    set(cpp11_flag "")
endif()

# possible C++14 flags
CHECK_CXX_COMPILER_FLAG("-std=c++14" has_cpp14_flag) # newer GCC/Clang
CHECK_CXX_COMPILER_FLAG("-std=c++1y" has_cpp1y_flag) # older GCC/Clang

if(has_cpp14_flag)
    set(cpp14_flag "-std=c++14")
elseif(has_cpp1y_flag)
    set(cpp14_flag "-std=c++1y")
else()
    message(WARNING "No required C++14 flag found, this could either be the case or missing support for your compiler.")
    set(cpp14_flag "")
endif()

# interface library that allows the use of generated compatiblity headers
# it sets the appropriate include directories
add_library(comp_target INTERFACE)
target_include_directories(comp_target INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/comp)

# option to change the macro prefix or namespace name
set(COMP_PREFIX "COMP_" CACHE STRING "prefix for all generated macros")
set(COMP_NAMESPACE "comp" CACHE STRING "namespace name")

# checks if ${code}, which is a feature test code, compiles
# provides option COMP_HAS_${name} defaulted to result
# flags specify the required compiler flags for the test
# and can be obtained via cpp11/14_flags
macro(comp_check_feature code name flags)
    set(CMAKE_REQUIRED_FLAGS "${flags}")
    check_cxx_source_compiles("${code}" has_${name})

    string(TOUPPER "${name}" macro_name)
    if(has_${name})
        option(COMP_HAS_${macro_name} "whether or not ${name} is available" ON)
    else()
        option(COMP_HAS_${macro_name} "whether or not ${name} is available" OFF)
    endif()
endmacro()

# writes test result into a new header file ${CMAKE_CURRENT_BINARY_DIR}/${name}.hpp
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
"#define ${COMP_PREFIX}HAS_${macro_name} ${result}
${workaround}")
endmacro()
