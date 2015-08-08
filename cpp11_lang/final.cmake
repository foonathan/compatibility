# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("struct base {virtual void foo() {}};
                   struct derived final : base {void foo() final {}};
                   int main(){}" final "${cpp11_flag}")
comp_gen_header(final
"
#ifndef ${COMP_PREFIX}FINAL
    #if ${COMP_PREFIX}HAS_FINAL
        #define ${COMP_PREFIX}FINAL final
    #else
        #define ${COMP_PREFIX}FINAL
    #endif
#endif
")
