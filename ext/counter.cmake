# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

# checks for __COUNTER__ macro, a common extension that expands to incresing integral numbers, starting with 0
comp_feature(counter "#include <cstddef>
                    #define CONCAT_IMPL(x, y) x##y
                    #define CONCAT(x, y) CONCAT_IMPL(x, y)
                    int CONCAT(a, __COUNTER__);
                    char CONCAT(a, __COUNTER__);
                    int main() {}" COMP_CPP98_FLAG)
