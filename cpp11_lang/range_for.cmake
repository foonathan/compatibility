# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(ranged_for "int main()
{ 
    int array[3] = { 1, 2, 3 }; 
    for (int& x : array) 
        x *= 2; 
}" COMP_CPP11_FLAG)

