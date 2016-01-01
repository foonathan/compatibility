# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(explicit_conversion_op
                    "struct foo
                    {
                        explicit operator int() {return 5;}
                        explicit operator bool() {return true;}
                    };
                    int main()
                    {
                        foo f;
                        int i = static_cast<int>(f);
                        bool b = static_cast<bool>(f);
                        if (f) {}
                    }" COMP_CPP11_FLAG)