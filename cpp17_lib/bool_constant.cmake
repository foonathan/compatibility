# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(bool_constant
                "#include <type_traits>
                int main()
                {
                    std::bool_constant b;
                }"
                COMP_CPP17_FLAG)
comp_workaround(bool_constant
"#include <type_traits>

namespace ${COMP_NAMESPACE}
{
    template <bool B>
    using bool_constant = std::integral_constant<bool, B>;

    typedef bool_constant<true> true_type;
    typedef bool_constant<false> false_type;
}" COMP_CPP11_FLAG)
