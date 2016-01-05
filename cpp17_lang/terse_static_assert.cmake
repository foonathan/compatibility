# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(terse_static_assert
                   "int main() {static_assert(true);}"
                   COMP_CPP17_FLAG)
comp_workaround(terse_static_assert
"#ifndef ${COMP_PREFIX}TERSE_STATIC_ASSERT
    #if ${COMP_PREFIX}HAS_TERSE_STATIC_ASSERT
        #define ${COMP_PREFIX}TERSE_STATIC_ASSERT(Expr) static_assert(Expr)
    #else
        #define ${COMP_PREFIX}TERSE_STATIC_ASSERT(Expr) static_assert(Expr, #Expr)
    #endif
#endif" COMP_CPP11_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(terse_static_assert __cpp_static_assert 201411)
endif()
