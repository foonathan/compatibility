# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(alignas "int main() {alignas(int) char c; alignas(16) int i;}" COMP_CPP11_FLAG)
comp_workaround(alignas "
#ifndef ${COMP_PREFIX}ALIGNAS
    #if ${COMP_PREFIX}HAS_ALIGNAS
        #define ${COMP_PREFIX}ALIGNAS(X) alignas(X)
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}ALIGNAS(X) __declspec(align(X))
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}ALIGNAS(X)  __attribute__((__aligned__(X)))
    #else
        #error \"no alignas replacement available\"
    #endif
#endif" COMP_CPP98_FLAG)
