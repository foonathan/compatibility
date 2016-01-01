# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(any
        "#include <experimental/any>

        int main()
        {
            std::experimental::any a(5);

            int i = std::experimental::any_cast<int>(a);
        }" COMP_CPP14_FLAG)
