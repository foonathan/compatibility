# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("[[deprecated]] int f(); int main() {}"
                   deprecated "${cpp14_flag}")
comp_gen_header(deprecated
"
#ifndef ${COMP_PREFIX}DEPRECATED
    #if ${COMP_PREFIX}HAS_DEPRECATED
        #define ${COMP_PREFIX}DEPRECATED [[deprecated]]
        #define ${COMP_PREFIX}DEPRECATED_MSG(Msg) [[deprecated(Msg)]]
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}DEPRECATED __attribute__((deprecated))
        #define ${COMP_PREFIX}DEPRECATED_MSG(Msg) __attribute__((deprecated(Msg)))
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}DEPRECATED __declspec(deprecated)
        #define ${COMP_PREFIX}DEPRECATED_MSG(Msg) __declspec(deprecated(Msg))
    #else
        #error \"no deprecated replacement available\"
    #endif
#endif
")