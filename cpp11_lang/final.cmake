# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(final "struct base {virtual void foo() {}};
                   struct derived final : base {void foo() final {}};
                   int main(){}" COMP_CPP11_FLAG)
comp_workaround(final
"#ifndef ${COMP_PREFIX}FINAL
    #if ${COMP_PREFIX}HAS_FINAL
        #define ${COMP_PREFIX}FINAL final
    #else
        #define ${COMP_PREFIX}FINAL
    #endif
#endif" COMP_CPP98_FLAG)
