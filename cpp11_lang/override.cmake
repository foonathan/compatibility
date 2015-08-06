# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("struct base {virtual void foo() {}};
                   struct derived : base {void foo() override {}};
                   int main(){}" override "${cpp11_flag}")
comp_gen_header(override
"
#ifndef ${COMP_PREFIX}OVERRIDE
    #if ${COMP_PREFIX}HAS_OVERRIDE
        #define ${COMP_PREFIX}OVERRIDE override
    #else
        #define ${COMP_PREFIX}OVERRIDE
    #endif
#endif
")
