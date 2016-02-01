# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(extension
        "#include <cstddef>

        int main()
        {
            __extension__ int x;
        }" COMP_CPP98_FLAG)
comp_workaround(extension
"#ifndef ${COMP_PREFIX}EXTENSION
    #if ${COMP_PREFIX}HAS_EXTENSION
        #define ${COMP_PREFIX}EXTENSION __extension__
    #else
        #define ${COMP_PREFIX}EXTENSION
    #endif
#endif" COMP_CPP98_FLAG)
