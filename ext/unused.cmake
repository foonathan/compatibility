# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(unused
        "#include <cstddef>

        int main()
        {
            // use GCC style attributes to get an error under MSVC
            __attribute__((__unused__)) int x;
        }" COMP_CPP98_FLAG)
comp_workaround(unused
"#ifndef ${COMP_PREFIX}UNUSED
    #if ${COMP_PREFIX}HAS_UNUSED
        #define ${COMP_PREFIX}UNUSED __attribute__((__unused__))
    #else
        #define ${COMP_PREFIX}UNUSED
    #endif
#endif

#define ${COMP_PREFIX}MARK_UNUSED(expr) do { if (false) (void)(expr); } while (false)
" COMP_CPP98_FLAG)
