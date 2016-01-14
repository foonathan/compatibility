# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(has_include "#include <cstddef>
                          #if !__has_include(<cstddef>)
                            #error \"not supported\"
                          #endif
                          int main() {}" COMP_CPP98_FLAG)
comp_workaround(has_include
"#ifndef ${COMP_PREFIX}HAS_INCLUDE
    #if ${COMP_PREFIX}HAS_HAS_INCLUDE
        #define ${COMP_PREFIX}HAS_INCLUDE(x) __has_include(x)
    #else
        #define ${COMP_PREFIX}HAS_INCLUDE(x) 0
    #endif
#endif" COMP_CPP98_FLAG)
