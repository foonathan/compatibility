# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# just generates a portable __PRETTY_FUNCTION__ macro
# don't test for it
set(COMP_HAS_PRETTY_FUNCTION 1 CACHE INTERNAL "" FORCE)
comp_gen_header(pretty_function
"
#ifndef ${COMP_PREFIX}PRETTY_FUNCTION
    #if defined(__GNUC__)
        #define ${COMP_PREFIX}PRETTY_FUNCTION __PRETTY_FUNCTION__
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}PRETTY_FUNCTION __FUNCSIG__
    #else
        #error \"no __PRETTY_FUNCTION__ macro available\"
    #endif
#endif
")
