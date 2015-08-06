# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main() {constexpr int foo = 1;}" constexpr "${cpp11_flag}")
comp_gen_header(constexpr
"
#ifndef ${COMP_PREFIX}CONSTEXPR
    #if ${COMP_PREFIX}HAS_CONSTEXPR
        #define ${COMP_PREFIX}CONSTEXPR constexpr
    #else
        #define ${COMP_PREFIX}CONSTEXPR const
    #endif
#endif

#ifndef ${COMP_PREFIX}CONSTEXPR_FNC
    #if ${COMP_PREFIX}HAS_CONSTEXPR
        #define ${COMP_PREFIX}CONSTEXPR_FNC constexpr
    #else
        #define ${COMP_PREFIX}CONSTEXPR_FNC inline
    #endif
#endif
")
