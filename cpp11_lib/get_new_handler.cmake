# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <new>
                   int main() {std::new_handler handler = std::get_new_handler();}"
                   get_new_handler ${cpp11_flag})
comp_gen_header(get_new_handler
"
#include <new>

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
}
")
