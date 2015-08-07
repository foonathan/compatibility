# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# small, dumb program that uses std::thread and std::mutex
comp_check_feature("#include <mutex>
                    #include <thread>

                    void foo() {}

                    int main()
                    {
                        std::thread thr(foo);
                        std::mutex m;
                    }
                    " threading_support "${cpp11_flag}")
comp_gen_header(threading_support "")
