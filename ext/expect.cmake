# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(expect
        "#include <cstddef>

        int main()
        {
            if (__builtin_expect(true, true))
                ;
        }" COMP_CPP98_FLAG)

comp_workaround(expect
"#ifndef ${COMP_PREFIX}EXPECT
    #if ${COMP_PREFIX}HAS_EXPECT
        #define ${COMP_PREFIX}EXPECT(expr, value) __builtin_expect((expr), value)
    #else
        #define ${COMP_PREFIX}EXPECT(expr, value) expr
    #endif
#endif

#define ${COMP_PREFIX}LIKELY(expr) ${COMP_PREFIX}EXPECT(expr, true)
#define ${COMP_PREFIX}UNLIKELY(expr) ${COMP_PREFIX}EXPECT(expr, false)
" COMP_CPP98_FLAG)
