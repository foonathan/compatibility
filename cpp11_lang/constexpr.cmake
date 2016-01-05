# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(constexpr "int main() {constexpr int foo = 1;}" COMP_CPP11_FLAG)
comp_workaround(constexpr
"#ifndef ${COMP_PREFIX}CONSTEXPR
    #if ${COMP_PREFIX}HAS_CONSTEXPR
        #define ${COMP_PREFIX}CONSTEXPR constexpr
    #else
        #define ${COMP_PREFIX}CONSTEXPR const
    #endif
#endif

#ifndef ${COMP_PREFIX}CONSTEXPR_FNC
    #if ${COMP_PREFIX}HAS_CONSTEXPR
        #define ${COMP_PREFIX}CONSTEXPR_FNC constexpr
    #else
        #define ${COMP_PREFIX}CONSTEXPR_FNC inline
    #endif
#endif" COMP_CPP98_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(constexpr __cpp_constexpr 200704)
endif()
