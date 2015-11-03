# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main() {alignas(int) char c; alignas(16) int i;}" alignas "${cpp11_flag}")
comp_gen_header(alignas
"
#ifndef ${COMP_PREFIX}ALIGNAS
    #if ${COMP_PREFIX}HAS_ALIGNAS
        #define ${COMP_PREFIX}ALIGNAS(X) alignas(X)
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}ALIGNAS(X) __declspec(align(X))
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}ALIGNAS(X)  __attribute__((__aligned__(X)))
    #else
        #error \"no alignas replacement available\"
    #endif
#endif
")
