# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(alias_template
              "template <typename A, typename B> struct foo {};
               template <typename A> using bar = foo<A, int>;
               int main(){}"
              COMP_CPP11_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(alias_template __cpp_alias_template 200704)
endif()
