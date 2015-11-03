# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main() {int i = alignof(int);}" alignof "${cpp11_flag}")
comp_gen_header(alignof
"
#ifndef ${COMP_PREFIX}ALIGNOF
    #if ${COMP_PREFIX}HAS_ALIGNOF
        #define ${COMP_PREFIX}ALIGNOF(x) alignof(x)
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}ALIGNOF(x) __alignof(x)
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}ALIGNOF(x) __alignof__(x)
    #else
        #error \"no alignof replacement available\"
    #endif
#endif
")