# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(pretty_function "#include <cstddef>
                             int main() {(void)__PRETTY_FUNCTION__;}"
                            COMP_CPP98_FLAG)
comp_workaround(pretty_function
"#ifndef ${COMP_PREFIX}PRETTY_FUNCTION
    #if ${COMP_PREFIX}HAS_PRETTY_FUNCTION || defined(__GNUC__)
        #define ${COMP_PREFIX}PRETTY_FUNCTION __PRETTY_FUNCTION__
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}PRETTY_FUNCTION __FUNCSIG__
    #else
        #error \"no __PRETTY_FUNCTION__ macro available\"
    #endif
#endif" COMP_CPP98_FLAG)
