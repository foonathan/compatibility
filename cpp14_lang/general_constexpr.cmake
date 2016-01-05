# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(general_constexpr
             "constexpr int foo() {int i = 0; return i;} int main() {}" COMP_CPP14_FLAG
             cpp11_lang/constexpr)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(general_constexpr __cpp_constexpr 201304)
endif()
