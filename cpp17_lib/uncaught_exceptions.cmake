# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(uncaught_exceptions
                    "#include <exception>
                    int main()
                    {
                        int count = std::uncaught_exceptions();
                    }" COMP_CPP17_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(uncaught_exceptions __cpp_uncaught_exceptions 201411)
endif()
