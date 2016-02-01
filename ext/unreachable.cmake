# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(unreachable
        "#include <cstddef>

        int main()
        {
            __builtin_unreachable();
        }" COMP_CPP98_FLAG)
comp_workaround(unreachable
"#ifndef ${COMP_PREFIX}UNREACHABLE
    #if ${COMP_PREFIX}HAS_UNREACHABLE
        #define ${COMP_PREFIX}UNREACHABLE __builtin_unreachable()
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}UNREACHABLE __assume(0)
    #else
        #define ${COMP_PREFIX}UNREACHABLE
    #endif
#endif
" COMP_CPP98_FLAG)
