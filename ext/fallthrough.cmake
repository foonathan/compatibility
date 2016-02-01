# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(fallthrough
        "#include <cstddef>

        int main()
        {
            int a = 0;
            switch (3)
            {
            case 2:
                ++a;
                [[clang::fallthrough]];
            case 3:
                ++a;
                break;
            }
        }" COMP_CPP11_FLAG)
comp_workaround(fallthrough
"#ifndef ${COMP_PREFIX}FALLTHROUGH
    #if ${COMP_PREFIX}HAS_FALLTHROUGH
        #define ${COMP_PREFIX}FALLTHROUGH [[clang::fallthrough]]
    #else
        #define ${COMP_PREFIX}FALLTHROUGH
    #endif
#endif" COMP_CPP11_FLAG)
