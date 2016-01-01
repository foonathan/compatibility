# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(alignof "int main() {int i = alignof(int);}" COMP_CPP11_FLAG)
comp_workaround(alignof
"
#ifndef ${COMP_PREFIX}ALIGNOF
    #if ${COMP_PREFIX}HAS_ALIGNOF
        #define ${COMP_PREFIX}ALIGNOF(x) alignof(x)
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}ALIGNOF(x) __alignof(x)
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}ALIGNOF(x) __alignof__(x)
    #else
        #error \"no alignof replacement available\"
    #endif
#endif
" COMP_CPP98_FLAG)