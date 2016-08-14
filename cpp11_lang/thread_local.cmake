# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(thread_local "thread_local int i; int main() {auto ptr = &i;}" COMP_CPP11_FLAG)
comp_workaround(thread_local
"#ifndef ${COMP_PREFIX}THREAD_LOCAL
    #if ${COMP_PREFIX}HAS_THREAD_LOCAL
        #define ${COMP_PREFIX}THREAD_LOCAL thread_local
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}THREAD_LOCAL __thread
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}THREAD_LOCAL __declspec(thread)
    #else
        #error \"no thread_local replacement available\"
    #endif
#endif" COMP_CPP98_FLAG)
