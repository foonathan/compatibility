# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# comp_base.cmake - base functionality for all compatibility files

if(TARGET comp_target)
    return()
endif()

include(CheckCXXSourceCompiles)

# interface library that allows the use of generated compatiblity headers
# it sets the appropriate include directories
add_library(comp_target INTERFACE)
target_include_directories(comp_target INTERFACE ${CMAKE_CURRENT_BINARY_DIR})

# option to change the macro prefix or namespace name
set(COMP_PREFIX "COMP_" CACHE STRING "prefix for all generated macros")
set(COMP_NAMESPACE "comp" CACHE STRING "namespace name")

# checks if ${code}, which is a feature test code, compiles
# provides option COMP_HAS_${name} defaulted to result
# flags specify the required compiler flags for the test
# and can be obtained via cpp11/14_flags from cpp_standard.cmake
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

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${name}.hpp
"#define ${COMP_PREFIX}HAS_${macro_name} ${result}
${workaround}")
endmacro()
