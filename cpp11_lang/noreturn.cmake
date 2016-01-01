# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(noreturn "[[noreturn]] int f(); int main() {}" COMP_CPP11_FLAG)
comp_workaround(noreturn
"#ifndef ${COMP_PREFIX}NORETURN
    #if ${COMP_PREFIX}HAS_NORETURN
        #define ${COMP_PREFIX}NORETURN [[noreturn]]
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}NORETURN __attribute__((noreturn))
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}NORETURN __declspec(noreturn)
    #else
        #define ${COMP_PREFIX}NORETURN
    #endif
#endif" COMP_CPP98_FLAG)