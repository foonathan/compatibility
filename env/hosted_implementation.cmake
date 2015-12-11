# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

# uses macro __STDC_HOSTED__
comp_feature(hosted_implementation "#include <cstddef>
                    #if !_MSC_VER && !__STDC_HOSTED__
                        #error \"no hosted\"
                    #endif

                    int main() {}" COMP_CPP98_FLAG)
comp_workaround(hosted_implementation
"
// HAS_HOSTED_IMPLEMENTATION doesn't sond that nice... :D
#define ${COMP_PREFIX}HOSTED_IMPLEMENTATION ${COMP_PREFIX}HAS_HOSTED_IMPLEMENTATION
" COMP_CPP98_FLAG)
