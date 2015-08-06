# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# cpp_standard.cmake - interface targets to activate C++11 standards

if(TARGET comp_cpp11)
    return()
endif()

add_library(comp_cpp11 INTERFACE)
target_compile_options(comp_cpp11 INTERFACE ${cpp11_flag})

add_library(comp_cpp14 INTERFACE)
target_compile_options(comp_cpp14 INTERFACE ${cpp14_flag})
