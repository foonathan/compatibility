# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# cpp_standard.cmake - interface targets to activate C++11 standards

if(TARGET comp_cpp11)
    return()
endif()

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

add_library(comp_cpp11 INTERFACE)
target_compile_options(comp_cpp11 INTERFACE ${cpp11_flag})

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

add_library(comp_cpp14 INTERFACE)
target_compile_options(comp_cpp14 INTERFACE ${cpp14_flag})
