# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(get_terminate "#include <exception>
                            int main() {std::terminate_handler handler = std::get_terminate();}"
                            COMP_CPP11_FLAG)
comp_workaround(get_terminate
"#include <exception>

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_GET_TERMINATE
    inline std::terminate_handler get_terminate()
    {
        return std::get_terminate();
    }
#else
    inline std::terminate_handler get_terminate()
    {
        std::terminate_handler h = std::set_terminate(0);
        std::set_terminate(h);
        return h;
    }
#endif
}" COMP_CPP98_FLAG)