# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(assume
        "#include <cstddef>

        int main()
        {
            int x = 3;
            __assume(x == 3);
        }" COMP_CPP98_FLAG)
comp_workaround(assume
"#ifndef ${COMP_PREFIX}ASSUME
    #if ${COMP_PREFIX}HAS_ASSUME
        #define ${COMP_PREFIX}ASSUME(expr) __assume(expr)
    #elif ${COMP_PREFIX}HAS_UNREACHABLE
        #define ${COMP_PREFIX}ASSUME(expr) \
            do \
            { \
                if (!(expr)) \
                    ${COMP_PREFIX}UNREACHABLE; \
            } while (false)
    #else
        #define ${COMP_PREFIX}ASSUME(expr)
    #endif
#endif
" COMP_CPP98_FLAG ext/unreachable)
