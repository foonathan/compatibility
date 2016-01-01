# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(string_view
        "#include <experimental/string_view>

        int main()
        {
            std::experimental::string_view view(\"Hello World!\");
        }" COMP_CPP14_FLAG)
