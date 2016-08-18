# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(literal_op "#include <cstddef>
                   int operator\"\" _foo(const char *, std::size_t){return 0;} int main(){}"
                   COMP_CPP11_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(literal_op __cpp_user_defined_literals 200809)
endif()
