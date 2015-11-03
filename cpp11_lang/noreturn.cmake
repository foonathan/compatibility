# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("[[noreturn]] int f(); int main() {}"
                   noreturn "${cpp14_flag}")
comp_gen_header(noreturn
"
#ifndef ${COMP_PREFIX}NORETURN
    #if ${COMP_PREFIX}HAS_NORETURN
        #define ${COMP_PREFIX}NORETURN [[noreturn]]
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}NORETURN __attribute__((noreturn))
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}NORETURN __declspec(noreturn)
    #else
        #error \"no noreturn replacement available\"
    #endif
#endif
")