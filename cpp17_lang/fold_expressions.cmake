# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(fold_expressions
                    "template <typename ... Args>
                    bool all(Args... args) {return (args && ...);}
                    int main()
                    {
                        bool b = all(true, true, false, true);
                    }"
                   COMP_CPP17_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(fold_expressions __cpp_fold_expressions 201411)
endif()
