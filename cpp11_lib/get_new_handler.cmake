# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(get_new_handler "#include <new>
                   int main() {std::new_handler handler = std::get_new_handler();}"
                   COMP_CPP11_FLAG)
comp_workaround(get_new_handler
"#include <new>

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_GET_NEW_HANDLER
    inline std::new_handler get_new_handler()
    {
        return std::get_new_handler();
    }
#else
    inline std::new_handler get_new_handler()
    {
        std::new_handler h = std::set_new_handler(0);
        std::set_new_handler(h);
        return h;
    }
#endif
}" COMP_CPP98_FLAG)
