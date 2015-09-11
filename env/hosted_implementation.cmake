# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# uses macro __STDC_HOSTED__
comp_check_feature("#include <cstddef>
                    #if !_MSC_VER && !__STDC_HOSTED__
                        #error \"no hosted\"
                    #endif
                    
                    int main() {}
                    " hosted_implementation "")
comp_gen_header(hosted_implementation
"
// HAS_HOSTED_IMPLEMENTATION doesn't sond that nice... :D
#define ${COMP_PREFIX}HOSTED_IMPLEMENTATION ${COMP_PREFIX}HAS_HOSTED_IMPLEMENTATION
")
