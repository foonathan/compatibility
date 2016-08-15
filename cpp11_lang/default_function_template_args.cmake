# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

# Taken from: 
# http://www.open-std.org/jtc1/sc22/wg21/docs/cwg_defects.html#226
comp_feature(default_function_template_args 
    "template <class T, class U = double>
    void f(T t = 0, U u = 0)
    { (void)t; (void) u; }

    int main()
    {
        f(1, 'c');         // f<int,char>(1,'c')
        f(1);              // f<int,double>(1,0)
        // f();            // error: T cannot be deduced
        f<int>();          // f<int,double>(0,0)
        f<int,char>();     // f<int,char>(0,0)
        return 0;
    }" COMP_CPP11_FLAG)
