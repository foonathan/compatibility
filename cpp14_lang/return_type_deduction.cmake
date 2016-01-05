# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(return_type_deduction
        "auto foo()
        {
            return 2;
        }

        int main() {}" COMP_CPP14_FLAG)

comp_workaround(return_type_deduction
"#ifndef ${COMP_PREFIX}AUTO_RETURN
    #define ${COMP_PREFIX}AUTO_RETURN(...) decltype(__VA_ARGS__) {return (__VA_ARGS__);}
#endif" COMP_CPP11_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(return_type_deduction __cpp_return_type_deduction 201304)
endif()
