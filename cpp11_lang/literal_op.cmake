# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <cstddef>
                   int operator\"\"_foo(const char *, std::size_t){return 0;} int main(){}"
                   literal_op "${cpp11_flag}")
comp_gen_header(literal_op "")
