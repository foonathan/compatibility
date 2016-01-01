# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

# small, dumb program that uses std::thread and std::mutex
comp_feature(threading_support
            "#include <mutex>
            #include <thread>

            void foo() {}

            int main()
            {
                std::thread thr(foo);
                std::mutex m;
            }" COMP_CPP11_FLAG)
