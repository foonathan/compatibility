# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(deprecated "[[deprecated]] int f(); int main() {}" COMP_CPP14_FLAG)
comp_workaround(deprecated
"#ifndef ${COMP_PREFIX}DEPRECATED
    #if ${COMP_PREFIX}HAS_DEPRECATED
        #define ${COMP_PREFIX}DEPRECATED [[deprecated]]
        #define ${COMP_PREFIX}DEPRECATED_MSG(Msg) [[deprecated(Msg)]]
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}DEPRECATED __attribute__((deprecated))
        #define ${COMP_PREFIX}DEPRECATED_MSG(Msg) __attribute__((deprecated(Msg)))
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}DEPRECATED __declspec(deprecated)
        #define ${COMP_PREFIX}DEPRECATED_MSG(Msg) __declspec(deprecated(Msg))
    #else
        #define ${COMP_PREFIX}DEPRECATED
        #define ${COMP_PREFIX}DEPRECATED_MSG(Msg)
    #endif
#endif" COMP_CPP98_FLAG)