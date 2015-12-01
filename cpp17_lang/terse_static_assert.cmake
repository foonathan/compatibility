# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main() {static_assert(true);}"
                   terse_static_assert "${cpp17_flag}")
comp_gen_header(terse_static_assert
"
#ifndef ${COMP_PREFIX}TERSE_STATIC_ASSERT
    #if ${COMP_PREFIX}HAS_TERSE_STATIC_ASSERT
        #define ${COMP_PREFIX}TERSE_STATIC_ASSERT(Expr) static_assert(Expr)
    #else
        #define ${COMP_PREFIX}TERSE_STATIC_ASSERT(Expr) static_assert(Expr, #Expr)
    #endif
#endif
")
