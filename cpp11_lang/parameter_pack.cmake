# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(parameter_pack "template <typename... Tn>
void f(const Tn&... args);

template <typename T, typename... Tn>
void f(const T& t, const Tn&... rest)
{ (void)t; f(rest...); }

template <>
void f()
{ }

int main()
{ f(1, 2); f(\"one\", 2); f(1); f(); }
" COMP_CPP11_FLAG)

