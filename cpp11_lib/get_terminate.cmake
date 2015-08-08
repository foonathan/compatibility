# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <exception>
                   int main() {std::terminate_handler handler = std::get_terminate();}"
                   get_terminate ${cpp11_flag})
comp_gen_header(get_terminate
"
#include <exception>

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
}
")