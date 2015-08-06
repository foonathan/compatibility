# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main() {thread_local int i;}" thread_local ${cpp11_flag})
comp_gen_header(thread_local
"
#ifndef ${COMP_PREFIX}THREAD_LOCAL
    #if ${COMP_PREFIX}HAS_THREAD_LOCAL
        #define ${COMP_PREFIX}THREAD_LOCAL thread_local
    #elif defined(__GNUC__)
        #define ${COMP_PREFIX}THREAD_LOCAL __thread
    #elif defined(_MSC_VER)
        #define ${COMP_PREFIX}THREAD_LOCAL __declspec(thread)
    #else
        #error \"no thread_local replacement available\"
    #endif
#endif
")
