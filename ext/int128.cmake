# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(int128
        "#include <cstddef>

         int main()
         {
            __int128 i;
            unsigned __int128 u;
         }" COMP_CPP98_FLAG)
comp_workaround(int128
"namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_INT128
    ${COMP_PREFIX}EXTENSION typedef __int128 int128_t;
    ${COMP_PREFIX}EXTENSION typedef unsigned __int128 uint128_t;
#endif
}" COMP_CPP98_FLAG ext/extension)
