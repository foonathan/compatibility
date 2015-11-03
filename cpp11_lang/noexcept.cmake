# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("void foo() noexcept {} int main(){}" noexcept "${cpp11_flag}")
comp_gen_header(noexcept
"
#ifndef ${COMP_PREFIX}NOEXCEPT
    #if ${COMP_PREFIX}HAS_NOEXCEPT
        #define ${COMP_PREFIX}NOEXCEPT noexcept
    #else
        #define ${COMP_PREFIX}NOEXCEPT
    #endif
#endif

#ifndef ${COMP_PREFIX}NOEXCEPT_OP
    #if ${COMP_PREFIX}HAS_NOEXCEPT
        #define ${COMP_PREFIX}NOEXCEPT_OP(x) noexcept(x)
    #else
        #define ${COMP_PREFIX}NOEXCEPT_OP(x) false
    #endif
#endif
")
