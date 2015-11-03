# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main() {int i; decltype(i) j;}" decltype ${cpp11_flag})
comp_gen_header(decltype
"
#ifndef ${COMP_PREFIX}DECLTYPE
    #if ${COMP_PREFIX}HAS_DECLTYPE
        #define ${COMP_PREFIX}DECLTYPE(x) decltype(x)
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}DECLTYPE(X) __typeof__(x)
    #else
        #error \"no decltype replacement available\"
    #endif
#endif
")
