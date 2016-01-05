# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(quoted "#include <iomanip>
                     #include <sstream>

                     int main()
                     {
                        std::stringstream ss;
                        std::string foo = \"a b\";
                        ss << std::quoted(foo);
                        ss >> std::quoted(foo);
                     }" COMP_CPP14_FLAG)
if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(quoted __cpp_lib_quoted_string_io 201304)
endif()
