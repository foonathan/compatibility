# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <shared_mutex>
                    int main()
                    {
                        std::shared_mutex m;
                    }" shared_mutex "${cpp17_flag}")
comp_gen_header(shared_mutex "")